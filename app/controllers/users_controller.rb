class UsersController < ApplicationController
  include DailyMissionHelper
  include AchievementHelper
  include LevelHelper
  include CollectionHelper
  include LocaleHelper
  include PriseHelper
  include EnergyHelper
  include ManaHelper
  include PumpingHelper

  before_filter :authenticate_user!
  before_filter :set_locale
  before_filter :check_vip_mana!

  RATING_LIMIT = 15

  # GET /refresh
  def refresh
    save_user = false
    events = { done: true }
    @user = current_user

    events[:new_level]        = check_level!
    events[:achievements]     = check_achievements!
    events[:collection_items] = format_prises unprocessed_items
    events[:collections]      = format_prises check_collections!.as_json(except: [:collection_item])

    add_stars = @user.add_stars
    add_coins = @user.add_coins
    @user.add_stars = 0
    @user.add_coins = 0

    if add_stars != 0
      prise_for(@user).with_hash({ stars: add_stars }, "match_end_stars").give!
      save_user = true
    end

    if add_coins != 0
      prise_for(@user).with_hash({ coins: add_coins }, "match_end_coins").give!
      save_user = true
    end

    last_game_result = GameResult.last_for_user(@user).first
    if !last_game_result.nil? && last_game_result.id.to_s != @user.last_game_result_id.to_s
      @user.last_game_result_id = last_game_result.id
      user_result = last_game_result.get_user_result(@user)
      save_user = true
      @user.inc_dynamic_stat(:best_player) if user_result[:user_result].best

      StatsWorker.perform_for_user(@user, :match_end, {
        item: last_game_result.string_room_type,
        quantity: (last_game_result.bet_stars + last_game_result.bet_coins),
        custom: { 
          score: last_game_result.team_game_results.map(&:score),
          team_id: user_result[:team_id].as_json,
          user_result: user_result[:user_result].as_json
        }
      })
    end

    # Remove 0 equipment
    UserWeapon.zero_charged(@user).delete_all
    UserWeapon.each_overdue(@user) { |x| x.delete }
    UserWeapon.check_active(@user)

    # Save user
    @user.save if save_user

    render json: events
  end
  
  # GET /user
  def current
    @user = current_user
    combined_info = UsersHelper.combined_info(@user)
    combined_info[:current_volcano_energy] = get_volcano_energy
    render json: combined_info
  end

  # GET /user_items
  def user_items
    @user = current_user
    items = {}
    items[:avail_hair] = @user.avail_hair
    items[:avail_eye] = @user.avail_eye
    items[:avail_mouth] = @user.avail_mouth
    render json: items
  end

  # GET /user_default
  def user_default
    render json: UserDefault.first.as_json.merge!({
      points_per_level: MEGABALL_CONFIG['points_per_level'],
      club_price_list: MEGABALL_CONFIG['club_price_list']
    })
  end
  
  # GET /users/:_id
  def show
    return unless params.include? :_id
    @user = User.find_by _id: ApplicationHelper.check_int_param(params[:_id])
    @club = @user.club
    user = @user.public_json
    user['profile_url'] = @user.profile_url
    user['club'] = @club.nil? ? {} : @club.as_json
    user['weapons'] = UserWeapon.where(user_id: @user.id, active: true)
    UsersHelper.pump_points user, user['weapons']

    # Rates
    #default = UserDefault.first
    #pt = default.pumping_ticks - 1

    render json: user
  end

  # GET /users
  def users
    if params.include? :uids
      uids = params[:uids].split ','
    else
      uids = []
    end

    if params.include? :source
      @users = User.where 'oauth_providers.provider' => params[:source], 'oauth_providers.uid' => { '$in' => uids }
    elsif params.include? :uids
      @users = User.where '_id' => { '$in' => uids }
    end
    result = @users
    result = result.map{ |x| x.public_json } unless result.nil?
    render json: result
  end

  # GET /user/balance
  def balance
    render json: {real: current_user.stars, imagine: current_user.coins}
  end

  # GET /user/statistics
  def statistics
    @user = current_user
    render json: @user.as_json(:only => [
      :wins, :goals, :goal_passes, :friends_count, :coins,
      :played_in_group, :rods, :skill_usage, :dynamic_stats,
      :friends_count, :distance_walked, :rod_hits, :played_fast_matches,
      :ended_fast_matches, :created_rooms, :played_trainings,
      :distance_walked, :nitro_used, :ball_kicks, :player_kicks,
      :draws, :fails, :rating, :collections_done, :best_player,
      :gate_saves
    ])
  end

  # GET /user/statistics/:id
  def statistics_by_id
    if params.include? :id
      @user = User.find_by _id: params[:id]
    else
      @user = current_user
    end

    if not @user.club.nil? then @user[:club_short_name] = @user.club[:short_name] end

    render json: @user.as_json(only: [
      :played_fast_matches, :ended_fast_matches, :created_rooms, 
      :played_training, :distance_walked, :nitro_used, 
      :ball_kicks, :player_kicks, :goals, :goal_passes, 
      :rod_hits, :wins, :draws, :fails, :gate_saves, :rating, :experience, :club_short_name
    ])
  end

  # GET /user/results
  def results
    @user = current_user
    @game_result = GameResult.find @user.last_match_id

    unless @game_result.nil?
      @result = @game_result.get_user_result(@user)
      unless @result.nil?
        @user_result = @result[:user_result].as_json
        @user_result[:team] = @result[:team_id]
      end
    end

    if @game_result.nil?
      render json: {game_result: 'No match played'}
    else
      if @user_result.nil?
        @user_result = {team: 0}
      end
      @user_result[:game_play] = @game_result.game_play
      @user_result[:score] = @game_result.team_game_results.map do |x| 
        (x.leavers) ? 0 : x.score
      end
      @user_result[:game_result_id] = @game_result._id

      col_texture_id = @user.last_collection_item.nil? ? 0 : @user.last_collection_item['texture_id'].to_i
      @user_result[:collection_texture_id] = col_texture_id

      @user_result[:teams] = []

      @game_result.team_game_results.each do |team|
        @user_result[:teams].push team.as_json
      end

      render json: @user_result
    end
  end

  # POST /user/improve/:stat
  def improve
    @user = current_user
    errors = {}

    defaults = UserDefault.first

    if @user.points > 0
      if !params[:stat].nil? and params[:stat].is_a? String
        if ['kick_power', 'nitro_speed', 'mana_top'].include? params[:stat]
          puts "!!!!!!!!!!!!!!!!!!!!!!!"
          puts params.as_json
          improve_pump_param params[:stat], @user, defaults, errors
        elsif ['perk_nitro_repair_latency', 'perk_nitro_repair_speed', 'perk_nitro_dribbling_user', 
        'perk_super_kick_repair_enemy_kick_ball', 'perk_super_kick_repair_enemy_kick_player', 
        'perk_super_kick_slowdown_enemy', 'perk_mana_repair_speed','perk_mana_chance_to_return',
        'perk_mana_start_with_mana' ].include? params[:stat]
          improve_perk_param params[:stat], @user, defaults, errors
        end
      end
      errors.merge @user.errors
    else
      errors[:points] = 'not_enough_points'
    end

    if errors.empty?
      render json: @user
    else
      render json: errors
    end
  end

  # POST /save_log
  def save_log
    if params.include?(:log)
      user_log = UserLog.create user_id: current_user[:_id], log: params[:log]
      return render json: user_log
    end
    render json: { errors: ['No log attached'] }
  end

  # PUT/PATCH /user
  def update
    @user = current_user
    @user.room = Room.new unless @user.room?
    result = {}
    errors = {}

    if params.include?(:name)
      @user.name = ApplicationHelper.validate_user_name(params[:name])
    end

    @user.hair = params[:hair] if params.include? :hair
    @user.eye = params[:eye] if params.include? :eye
    @user.mouth = params[:mouth] if params.include? :mouth
    @user.friends_count = params[:friends_count].to_i if params.include? :friends_count 
    @user.sound_on = params[:sound_on] if params.include? :sound_on
    @user.music_on = params[:music_on] if params.include? :music_on
    @user.fullscreen_on = params[:fullscreen_on] if params.include? :fullscreen_on
    @user.have_seen_menu |= params[:have_seen_menu] if params.include? :have_seen_menu
    @user.user_control.from_hash params[:user_control] if params.include? :user_control
    @user.want_spectate = params[:want_spectate] == "true"

    if @user.first_time && params.include?(:first_time)
      @user.first_time = false
      StatsWorker.perform_for_user(@user, :learning_started, {})
    end

    if params.include? :stage
      @user.stage = params[:stage].to_i
      @user.experience += 100 if params[:stage].to_i == 7 #Now last learning scene

      StatsWorker.perform_for_user(@user, :learning_stage, {
        custom: { stage: @user.stage }
      });
    end

    if params.include? :plugin_status
      @user.plugin_status = params[:plugin_status][0..11]
      StatsWorker.perform_for_user(@user, :plugin_status, {
        custom: { status: @user.plugin_status }
      })
    end

    if params.include?(:weapons)
      user_weapon = UserWeapon.find_by(_id: params[:weapons][:_id], user_id: @user._id)
      puts "#{params[:weapons].as_json} <> #{user_weapon.as_json}"

      unless user_weapon.nil?
        #vip = UserWeapon.where(user_id: @user._id, light_new: true).count > 0
        user_weapon.active = params[:weapons][:active] == "true"
        user_weapon.update_time = Time.now.to_i
        user_weapon.save
        errors = errors.merge! user_weapon.errors
      end
    end

    if params.include?(:game_filters)
      default = UserDefault.first
      @user.filters_enabled = true
      @user.room.type = params[:game_filters][:type].to_i
      @user.room.password = params[:game_filters][:password]
      @user.room.name = ApplicationHelper.validate_user_name(params[:game_filters][:name])
      @user.room.game_play = params[:game_filters][:game_play]
      @user.room.level_from = params[:game_filters][:level_from].to_i
      @user.room.level_to = params[:game_filters][:level_to].to_i
      @user.room.bet_stars = default[:bet_stars][params[:game_filters][:bet_stars].to_i]
      @user.room.bet_coins = default[:bet_coins][params[:game_filters][:bet_coins].to_i]
      if @user.room.type==3 and @user.room.bet_stars==0 and @user.room.bet_coins==0
        render :json => { :error => 'not_allowed.zero_bet' }
        return
      end
      @user.room.max_players = params[:game_filters][:max_players].to_i
      @user.room.allow_spectators = params[:game_filters][:allow_spectators] == "true"
      @user.room.allow_skills = params[:game_filters][:allow_skills] == "true"
      @user.room.save
      errors = errors.merge! @user.room.errors
    end

    if params.include?(:playing_room)
      @user.filters_enabled = false
      @user.room_id = params[:playing_room]
      @user.server = params[:server]
      @user.room.type = params[:game_type].to_i
      @user.room.password = params[:password]
    end

    @user.save
    errors = errors.merge! @user.errors

    render :json => {:error => errors } #, :status => 400
  end

  # GET /user/check_weapons
  def check_weapons
    UserWeapon.check_active(current_user)
    render :json =>  {:success => true }
  end

  # GET /user/messages
  def messages
    limit = params[:limit] || 10
    type = params[:type]
    type = (['gt', 'lt'].include? type) ? type : 'gt'
    @user = current_user

    user_messages = Message
      .any_of({user_id: @user._id}, {user_id: 0})
      .order_by([:date, :DESC])
  
    if params.include? :offset
      messages = user_messages.where(_id: {"$#{type}" => params[:offset]})
      messages = messages.limit limit if type == 'lt'
    else
      messages = user_messages.where(_id: {:'$gt' => @user.last_read_mail})
      if messages.count < limit
        messages = user_messages.limit(limit)
      end
    end

    json = messages.as_json.map { |x| x['read'] = x['_id'] <= @user.last_read_mail; x }

    render :json => json
  end

  # POST /user/read_message/:id
  def read_message
    @user = current_user
    user_message = Message
      .any_of({user_id: @user._id}, {user_id: 0})
      .order_by([:date, :DESC])
      .first

    id = params[:id]
    if not id.nil? 
      id = id.to_i
      if id <= user_message._id and id > @user.last_read_mail 
        @user.last_read_mail = id
        @user.save
      end
    end

    render :json => {updated: true}
  end

  # GET /user/ratings/:type
  def ratings
    user = current_user

    field = case params[:type]
      when 'daily_rating' then :daily_place
      when 'monthly_rating' then :monthly_place
      when 'goals' then :goals_place
      when 'passes' then :passes_place
      when 'gate_saves' then :gate_saves_place
      else :place
    end

    ratings = User.where(field => { :$gt => 0 })
                  .order_by([field, :asc]).limit(RATING_LIMIT).entries

    ratings << user
    render :json => ratings.map { |x| x.public_json }
  end

  # GET /user/achievements
  def achievements
    ach = Achievement.all.as_json
    user_ach = current_user.user_achievement

    user_ach.each do |x|
      i = ach.index{ |a| a['_id'] == x.achievement }
      break if i.nil?
      ach[i] = ach[i].merge x.as_json except: :_id unless i.nil?
      ach[i]['achievement_entry'] = ach[i]['achievement_entry'].map do |entry|
        format_prise entry
      end
    end

    render :json => ach
  end

  # GET /user/collections
  def collections
    @user = current_user
    collections = Collection.all.map{ |x| x.join_user @user }
    render :json => format_prises(collections.as_json)
  end

  # GET /user/check_first_prise
  def check_first_prise
    @user = current_user
    defaults = UserDefault.first
    if not @user.money_for_first_games_received and @user.ended_fast_matches >= defaults.games_for_star
        @user.acid.contribute_currency defaults.stars_for_first_games, :real, 'first_games'
        @user.money_for_first_games_received = true
        @user.save
    end

    render :json => @user.money_for_first_games_received
  end
end
