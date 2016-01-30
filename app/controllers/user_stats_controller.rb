class UserStatsController < ApplicationController
  #before_filter :authenticate_admin!
  before_filter :init
  
  # Init From/To vars for filters
  def init
    @from_day = params[:from].nil? ? Time.parse("2013-09-01") : Time.parse(params[:from])
    @to_day = params[:to].nil? ? Time.now : Time.parse(params[:to]) + (60 * 60 * 24 - 1)
    @visits = Visit.asc(:time_in).where("this.time_in >= #{@from_day.to_i} && this.time_in <= #{@to_day.to_i}")
  end
  
  # Monthly Active Users
  def mau
    render json: get_mau(@visits)
  end

  def get_mau(visits)

    mau = {}
    month_users = {}

    # init first all months
    from_date = @from_day.to_date
    days_count = (@to_day.to_date - from_date).round
    for d in 0..days_count
       month = from_date.strftime "%Y-%m"
       if month_users[month].nil? then month_users[month] = {} end
       from_date += 1
    end
    
    # then fill with data
    visits.each do |v| # all in right order
      time = Time.at(v.time_in)
      month = time.strftime "%Y-%m"
      date = time.strftime "%Y-%m-%d"
      if month_users[month].nil? then month_users[month] = {} end
      if month_users[month][v.user_id].nil? then month_users[month][v.user_id] = {} end
      month_users[month][v.user_id][date] = 1
    end
    # count unique users in each month with 4 more visits in different days
    month_users.each do |month, users|
      mau[month] = 0
      users.each do |day, visits|
        if visits.count >= 4 then mau[month] += 1 end
      end
    end

    return mau
  end

  # Monthly Super Active Users
  def msau
    render json: get_msau(@visits)
  end

  def get_msau(visits)

    mau = {}
    users = {}
	
    n_days_seconds = 3600 * 24 * 4 # four days

    visits.each do |v| # all in right order
      user = users[v.user_id]
      time = Time.at(v.time_in)
      month = time.strftime "%Y-%m"
       
      if user.nil?
        user = users[v.user_id] = {:active_months => {}, :time => v.time_out, :last_month => month }
        user[:active_months][month] = 1 # first visit of this user
        next
      else
        next if !(user[:active_months][month].nil?) && user[:active_months][month] == 0 # not active in this month
      end
       
      # no visits for a N days?
      if (v.time_in - user[:time]) > n_days_seconds
        if month == user[:last_month] # check only equal months visits
          user[:active_months][month] = 0 #not active in this month anymore
          next
        end
      end
       
      if user[:active_months][month].nil? then user[:active_months][month] = 0 end # first visit for this month ?

      user[:time] = v.time_out
      user[:last_month] = month
      user[:active_months][month] += 1 #count visits per month
    end
     
    users.each do |uid, user|
      user[:active_months].each do |month, active|
        if active >= 4 # 4 more visits in this month ?
          if mau[month].nil? then mau[month] = 0 end
          mau[month] += 1
        end
      end
    end
     
    return mau
  end
  
  # Daily Active Users
  def dau
    render json: get_dau(@visits)
  end

  def get_dau(visits)

    dau = {}
    day_users = {}

    # init first all days
    from_date = @from_day.to_date
    days_count = (@to_day.to_date - from_date).round
    for d in 0..days_count
       date = from_date.strftime "%Y-%m-%d"
       if day_users[date].nil? then day_users[date] = {} end
       from_date += 1
    end
    
    # then fill with data
    visits.each do |v| # all in right order
      time = Time.at(v.time_in)
      date = time.strftime "%Y-%m-%d"
      if day_users[date].nil? then day_users[date] = {} end
      day_users[date][v.user_id] = 1
    end
    # count unique users in each day
    day_users.each do |date, users|
      dau[date] = users.count
    end

    return dau
  end

  def dau_mau
    mau = get_mau(@visits)
    dau = get_dau(@visits)
    avg_dau = {}
    dau_in_month = {}
    dau.each do |date, count|
      month = Time.parse(date).strftime "%Y-%m"
      if avg_dau[month].nil? then avg_dau[month] = 0 end
      avg_dau[month] += count
      if dau_in_month[month].nil? then dau_in_month[month] = 0 end
      dau_in_month[month] += 1
    end

    dau_in_month.each do |month, count|
      avg_dau[month] /= count
    end

    result = {}
    avg_dau.each do |month, count|
      result[month] = {:avg_dau => count, :mau => mau[month]}
    end

    render json: result
  end
  
  # user came again next month
  def users_retention
    month_users = {}
	
    uret = {}
	
    @visits.each do |v| # all in right order
      time = Time.at(v.time_in)
      next if time < @from_day
      if time > @to_day then break end
      month = time.strftime "%Y-%m"
      if month_users[month].nil? then month_users[month] = {:uids => {}, :month => month} end
      if month_users[month][:uids][v.user_id].nil? then month_users[month][:uids][v.user_id] = 0 end
      month_users[month][:uids][v.user_id] += 1
    end
    
    month_users_ar = month_users.values.sort {|x,y| x[:month] <=> y[:month]} # sort by month

    for index in 1 ... month_users_ar.size # skip first month
      info = month_users_ar[index]
      month = info[:month]
      # how much (in %) from last month users came again in this month
      last_month_users = month_users_ar[index-1]
      uret[month] = {:count => 0, :total => last_month_users[:uids].count }
      last_month_users[:uids].each do |uid, count|
        if !(info[:uids][uid].nil?) then uret[month][:count] += 1 end
      end
    end
    
    render json: uret
  end
  # active user came again next month
  def active_users_retention
    
  end
  
  # active user active again next month
  def super_active_users_retention
    
  end
  
  def authenticate_admin!
    authenticate_user!
    if Rails.env.release? and not current_user.admin?
      raise ActionController::RoutingError.new "Admins only"
    end
  end

  def daily_payments_count
    payments = AcidPaymentTransaction.where("this.date >= '#{@from_day.to_datetime}' && this.date <= '#{@to_day.to_datetime}'")

    dpmts = {}
    payments.each do |p|
      date = p.date.strftime "%Y-%m-%d"
      if dpmts[date].nil? then dconv[date] = { :payers => {} } end
      dpmts[date][:payers][p.user_id] = 1
    end
    dpmts.each do |date, info|
      info[:payers] = info[:payers].count
    end

    render json: dpmts
  end
  
  def daily_conversion
    payments = AcidPaymentTransaction.where("date BETWEEN DATE('#{@from_day.to_datetime}') AND DATE('#{@to_day.to_datetime}')")
    dau = get_dau(@visits)
    dconv = {}

    # init first all days
    from_date = @from_day.to_date
    days = (@to_day.to_date - from_date).round
    for d in 0..days
       date = from_date.strftime "%Y-%m-%d"
       if dconv[date].nil? then dconv[date] = {:dau => dau[date], :payers => {} } end
       from_date += 1
    end

    payments.each do |p|
      date = p.date.strftime "%Y-%m-%d"
      if dconv[date].nil? then dconv[date] = {:dau => dau[date], :payers => {} } end
      dconv[date][:payers][p.user_id] = 1
    end
    dconv.each do |date, info|
      info[:payers] = info[:payers].count
    end

    render json: dconv
  end

  def monthly_conversion
    payments = AcidPaymentTransaction.where("date BETWEEN DATE('#{@from_day.to_datetime}') AND DATE('#{@to_day.to_datetime}')")
    mau = get_mau(@visits)
    mconv = {}
    payments.each do |p|
      date = p.date.strftime "%Y-%m"
      if mconv[date].nil? then mconv[date] = {:mau => mau[date], :payers => {} } end
      mconv[date][:payers][p.user_id] = 1
    end
    mconv.each do |date, info|
      info[:payers] = info[:payers].count
    end

    render json: mconv
  end

  def arppu
    payments = AcidPaymentTransaction.where("date BETWEEN DATE('#{@from_day.to_datetime}') AND DATE('#{@to_day.to_datetime}')")
    result = {}
    payments.each do |p|
      date = p.date.strftime "%Y-%m"
      if result[date].nil? then result[date] = {:payers => {}, :revenue => 0 } end
      result[date][:revenue] += p.gate_currency_amount
      result[date][:payers][p.user_id] = 1
    end
    result.each do |date, info|
      result[date][:payers] = result[date][:payers].count
    end
   
    render json: result
  end

  def orders_per_category
    payments = AcidOrder.where("date BETWEEN DATE('#{@from_day.to_datetime}') AND DATE('#{@to_day.to_datetime}')")
    opc = {}

    # init first all days
    from_date = @from_day.to_date
    days = (@to_day.to_date - from_date).round
    for d in 0..days
       date = from_date.strftime "%Y-%m-%d"
       if opc[date].nil? then opc[date] = {} end
       from_date += 1
    end

    payments.each do |p|
      date = p.date.strftime "%Y-%m-%d"
      if opc[date].nil? then opc[date] = {} end
      next if p.product_id == 0
      item = Item.find(p.product_id)
      next if item.nil?
      if opc[date][item.category].nil? then opc[date][item.category] = 0 end
      opc[date][item.category] += 1
    end

    render json: opc
  end

  def sharks
    payments = AcidPaymentTransaction.where("date BETWEEN DATE('#{@from_day.to_datetime}') AND DATE('#{@to_day.to_datetime}')")
    payers = {}
    payments.each do |p|
      date = p.date.strftime "%Y-%m"
      if payers[date].nil? then payers[date] = {} end
      if payers[date][p.user_id].nil? then payers[date][p.user_id] = 0 end
      payers[date][p.user_id] += p.gate_currency_amount
    end
    render json: payers
  end

  def purchase
    items  = Hash[Item.all.map { |item| [ item._id, item ] }]
    orders = AcidOrder.where("date BETWEEN DATE('#{@from_day.to_datetime}') AND DATE('#{@to_day.to_datetime}')")
    values = Hash[ items.map { |key, item| [ item.title, 0 ] } ]
    admins = User.where(admin: 'true').map { |user| user._id }

    result = {}

    orders.sort.each do |order|
        date = order.date.strftime '%Y-%m-%d'
        item = items[order.product_id]

        next if admins.any? { |id| id == order.user_id }
        next if item.nil?

        if result[date].nil?
          result[date] = Hash[ items.map { |key, item| [ item.title, [ 0, item.texture, item.stars, item.coins, 0, 0] ] } ]
        end

        result[date][item.title][0] += 1

        if order.balance_type == 1 then
          result[date][item.title][4] += order.amount
        else
          if order.balance_type == 2 then
            result[date][item.title][5] += order.amount
          end
        end

        values[item.title] = [result[date][item.title][0], result[date][item.title][4], result[date][item.title][5]]

    end

    render json: result
  end


  def faces_purchase
    items  = Hash[Item.all.select{ |item| item.category == 5 }.map { |item| [ item._id, item ] }]
    orders = AcidOrder.all#where("date BETWEEN DATE('#{@from_day.to_datetime}') AND DATE('#{@to_day.to_datetime}')")
    values = Hash[ items.map { |key, item| [ item.title, 0 ] } ]
    admins = User.where(admin: 'true').map { |user| user._id }
    result = {}

    orders.sort.each do |order|
      date = order.date.strftime '%Y-%m-%d'
      item = items[order.product_id]

      next if admins.any? { |id| id == order.user_id }
      next if item.nil?

      if result[date].nil?
        result[date] = Hash[ items.map { |_, item| [ item._id, [ 0, item.texture, item.stars, item.coins, 0, 0, item.item_contents.first.type ] ] } ]
      end

      result[date][item._id][0] += 1

      if order.balance_type == 1 then
        result[date][item._id][4] += order.amount
      else
        if order.balance_type == 2 then
          result[date][item._id][5] += order.amount
        end
      end

      values[item._id] = [result[date][item._id][0], result[date][item._id][4], result[date][item._id][5]]
    end

    render json: result
  end

  def level_money_dependency
    users = User.where(admin: 'false')
    levels = (levels = UserDefault.all.first.levels).zip(levels.drop(1))
    result = []

    levels.each do |level|
      current_users = users.select { |user| level[1].nil? ? level[0] <= user.experience : level[0] <= user.experience && user.experience < level[1] }

      result.push([levels.select{ |x| x[0] <= level[0] }.length, current_users.map { |u| [u.acid.real_balance, u.acid.imagine_balance] }.transpose.map { |x| x.reduce(:+) }])
    end

    render json: result
  end

  def level_money_dependency_average
    users = User.where(admin: 'false')
    levels = (levels = UserDefault.all.first.levels).zip(levels.drop(1))
    result = []

    levels.each do |level|
      current_users = users.select { |user| level[1].nil? ? level[0] <= user.experience : level[0] <= user.experience && user.experience < level[1] }
      res = current_users.map { |u| [u.acid.real_balance, u.acid.imagine_balance] }.transpose.map { |x| x.reduce(:+) }
            .collect { |x| x / current_users.length.to_f }

      result.push([levels.select{ |x| x[0] <= level[0] }.length, res])

    end

    render json: result
  end

  def index
     render text: '', layout: 'user_stats'
  end
end
