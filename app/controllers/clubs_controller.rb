class ClubsController < ApplicationController
  include ClubsHelper
  before_filter :authenticate_user!
  load_and_authorize_resource :class => :clubs

  MAX_ROLE = 1
  MIN_ROLE = 0

  # GET /club/all
  def all
    time_bound = Time.now.to_i - MEGABALL_CONFIG['club_defaults']['hide_for_inactivity'].to_i
    criteria = Club.where(:last_updated.gt => time_bound).order_by([:rating, :desc]).for_zone(current_user.zone)
    criteria = criteria.where(:level.gte => params[:level_from]) \
      if params.include? :level_from
    criteria = criteria.where(:level.lte => params[:level_to]) \
      if params.include? :level_to
    criteria = criteria.full_text_search(params[:text], allow_empty_search: true) \
      if params.include? :text
    criteria = criteria.limit(params[:limit]) \
      if params.include? :limit

    owners = Hash[
      User.where(:_id.in => criteria.map{ |x| x.creator_id })
          .map{ |x| [x._id, x.public_json] } 
    ]

    render json: criteria.each_with_index.map { |x, i| 
      x = x.as_json(noplace: true)
      x['owner'] = owners[x['creator_id']]
      x['place'] = i + 1
      x 
    }
  end

  # GET /club
  def show
    club = current_user.club
    return render json: {} if club.nil?

    if (Time.now - club.ratings_update).to_i > 
        MEGABALL_CONFIG['club_defaults']['ratings_refresh'].to_i
      club.ratings_update = Time.now
      club.recalc_ratings
      club.save!
    end

    club_users = ClubUser.where(cid: club._id).order_by([:place_in_club, :desc]).to_a
    users = Hash[User
                  .where(:_id.in => club_users.map{|x| x.uid})
                  .map{ |x| [x._id, x] }]
    club['users'] = club_users.map{ |x| x.as_json.merge users[x.uid].public_json }
    render json: club.as_json
  end

  # GET /club/user
  def user
    user = UsersHelper.combined_info current_user
    club = current_user.club
    user['club'] = (club.nil?) ? {} : club.as_json
    render json: user.as_json
  end

  # GET /club/requests
  def show_requests
    users = ClubUserRequest.where(cid: current_user.club._id)
    render json: User
      .where(:_id.in => users.map{ |x| x.uid })
      .map{ |x| x.public_json }
  end

  # GET /club/upgrade
  def upgrade
    club = current_user.club
    level_info = club.level_info
    amount = level_info['upgrade'][currency.to_s]
    result = {}

    club_transaction do |acid_club|
      if club.level >= MEGABALL_CONFIG['club_defaults']['max_level']
        result[:error] = :reached_max_level
        break
      end

      unless acid_club.can_pay_for?(currency, amount)
        result[:error] = :not_enough_money
        break
      end

      order = AcidClubOrder.new_system_order(currency)
      order.amount = amount
      order.product_id = 0 # default for upgrade
      order.acid_club = acid_club
      order.balance = acid_club.balance_for(currency)

      club.level += 1
      unless club.valid?
        result[:error] = club.errors
        break
      end
      club.save!

      acid_club.buy(currency, amount)
      order.save!
    end

    render json: result
  end

  # POST /club/join/:id
  def join
    club = Club.find(params[:cid].to_i)
    return render json: {error: :club_not_found} if club.nil?
    
    return render json: {error: :club_is_full} \
      if ClubUser.where(cid: club._id).count >= club.max_players

    req = ClubUserRequest.create(
      uid: current_user._id, 
      cid: params[:cid].to_i)

    render json: ((req.errors.empty?) ? req : req.errors)
  end

  # POST /club/accpet/:id
  def accept
    uid = params[:uid].to_i
    club = current_user.club
    req = ClubUserRequest.where(uid: uid, cid: club._id).first
    return render json: {error: :request_not_found} if req.nil?

    current_user.club_id = club._id
    current_user.save

    ClubUserRequest.where(uid: uid).delete_all
    res = ClubUser.create(uid: uid, cid: club._id)
    club.recalc_ratings
    club.save

    count = ClubUser.where(cid: club._id).count
    if count >= club.level_info['max_players']
      ClubUserRequest.where(cid: club._id).delete_all
    end

    Message.create message: club.name, type: 'club_accepted', user_id: uid
    render json: ((res.errors.empty?) ? res : res.errors)
  end

  # POST /club/reject_all/
  def reject_all
    club = current_user.club
    ClubUserRequest.where(cid: club._id).delete_all
    render json: {}
  end

  # POST /club/reject/:id
  def reject
    uid = params[:uid].to_i
    club = current_user.club
    req = ClubUserRequest.where(uid: uid, cid: club._id).first
    return {error: :request_not_found} if req.nil?
    req.delete
    Message.create message: club.name, type: 'club_rejected', user_id: uid
    render json: {}
  end

  # POST /club/kick/:id
  def kick
    uid = params[:uid].to_i
    club = current_user.club
    return {error: :user_not_found} \
      if ClubUser.where(uid: uid, cid: club._id).count <= 0
    ClubUser.where(uid: uid).delete_all
    render json: {}
  end

  # POST /club/role/:uid
  def role
    render json: (item_transaction 'role' do |acid_club, result|
      role = params[:role].to_i
      role = (role < MIN_ROLE) ? MIN_ROLE : (role > MAX_ROLE) ? MAX_ROLE : role

      user = ClubUser.where(uid: params[:uid].to_i, cid: current_user.club._id).first
      if user.nil?
        result[:error] = :user_not_found
        break result
      end

      if user.uid == current_user._id
        result[:error] = :cant_operate_on_self
        break result
      end

      if user.role == role
        result[:error] = :same_role
        break result
      end

      user.role = role
      user.save!
    end)
  end

  # POST /club/leave
  def leave
    render json: if current_user.club_user.administrator?
      destroy_club
    else
      leave_club
    end
  end

  # PUT/PATCH /club
  def update
    @club = current_user.club

    @club.status_message = 
      sanitize(params[:status_message]) \
      if params.include? :status_message

    render json: @club.save
  end

  # POST /new
  def new_club
    item = MEGABALL_CONFIG['club_price_list']['create']
    amount = item[currency.to_s]
    result = {}

    short_name = ApplicationHelper.validate_club_short_name(params[:short_name])
    name = ApplicationHelper.validate_club_name(params['name'])
    status_message = sanitize(params[:status_message])

    user_transaction do |acid_user|
      if not item['user_level'].nil? and current_user.level < item['user_level'].to_i
        result[:error] = :level_is_low
        break
      end

      unless acid_user.can_pay_for?(currency, amount)
        result[:error] = :not_enough_money
        break
      end

      club = Club.new({
        short_name: short_name, 
        name: name, 
        creator_id: current_user._id,
        zone: current_user.zone,
        status_message: status_message
      })
      unless club.valid?
        result[:error] = club.errors
        break
      end
      club.recalc_ratings
      club.save

      ClubUser.create! uid: current_user._id, cid: club._id, role: 2
      ClubUserRequest.where(uid: current_user._id).delete_all
      acid_user.buy(currency, amount)
    end

    render json: result
  end

  # POST /club/rename
  def rename
    params.require(:short_name)
    params.require(:name)

    club = current_user.club
    short_name = ApplicationHelper.validate_club_short_name(params[:short_name])
    name = ApplicationHelper.validate_club_name(params[:name])

    render json: (item_transaction 'rename' do |acid_club, result|
      if club.name == name and club.short_name == short_name
        result[:error] = :same_name
        break result
      end

      # Change name
      club.name = name unless name.nil?
      club.short_name = short_name unless short_name.nil?
      unless club.valid?
        result[:error] = club.errors
        break result
      end

      club.save!
      true
    end)
  end

  # POST /club/update_logo
  def update_logo
    logo = params.require('logo')
    club = current_user.club

    if club.logo?
      render json: (item_transaction 'update_logo' do |acid_club, result|
        club.logo = logo
        unless club.valid?
          result[:error] = club.errors
          break result
        end
        club.save!
        true
      end)
    else
      club.logo = logo
      unless club.valid?
        return render json: {error: club.errors}
      end
      club.save!
      render json: {}
    end
  end

  private

  def destroy_club
    club = current_user.club
	# TODO update User.club_id
    ClubUser.where(cid: club._id).delete_all
    ClubUserRequest.where(cid: club._id).delete_all
    club.delete
    current_user.public_json
  end

  def leave_club
    current_user.club_user.delete
    current_user.public_json
    current_user.club_id = 0
    current_user.save
  end

  # --

  def club_transaction(&block)
    AcidClub.transaction do
      block.call AcidClub.find(current_user.club._id, lock: true)
    end
  end

  def user_transaction(&block)
    AcidUser.transaction do
      block.call AcidUser.find(current_user._id, lock: true)
    end
  end

  def item_transaction(item, args={}, &block)
    club = current_user.club
    item = MEGABALL_CONFIG['club_price_list'][item]
    amount = item[currency.to_s]
    result = {}

    club_transaction do |acid_club|
      # Check level
      if not item['level'].nil? and club.level < item['level']
        result[:error] = :level_is_low
        break
      end

      # Money
      unless acid_club.can_pay_for?(currency, item[currency.to_s])
        result[:error] = :not_enough_money
        break
      end
      
      # Create order
      order = AcidClubOrder.new_system_order(currency)
      order.amount = amount
      order.product_id = item['product_id']
      order.acid_club = acid_club
      order.balance = acid_club.balance_for(currency)

      unless block.call acid_club, result
        break
      end

      acid_club.buy(currency, amount)
      order.save!
    end

    result
  end

  def currency
    @currency ||= (params[:currency] == 'stars') ? :real : :imagine
  end

end
