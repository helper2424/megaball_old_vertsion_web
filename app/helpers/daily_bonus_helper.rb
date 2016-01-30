module DailyBonusHelper

  def self.needs_bonus?(current_user)
    current_user.last_daily_bonus.to_i == 0 \
      or current_user.days_since_last_daily_bonus == 1
  end

  def self.shift_bonus_day!(current_user)
    count = current_user.days_since_last_daily_bonus
    last_daily_bonus = current_user.last_daily_bonus.to_i
    puts (current_user.last_daily_bonus = Time.now.gmtime).to_json
    if count == 1
      current_user.days_in_row += 1
      current_user.days_in_row = 1 if current_user.days_in_row > MEGABALL_CONFIG['max_days_in_row']
      current_user.days_in_row
    elsif count != 0 or last_daily_bonus == 0
      current_user.days_in_row = 1
    else 
      0
    end
  end

  def self.bonus_for(current_user)
    case current_user.days_in_row
    when 1 then self.one_day_for current_user
    when 2 then self.two_days_for current_user
    when 3 then self.three_days_for current_user
    when 4 then self.four_days_for current_user
    when 5 then self.random_bonus current_user
    end
  end

  def self.one_day_for current_user
    current_user.acid.contribute_currency 5, :imagine, 'daily_bonus'
    "coins5"
  end

  def self.two_days_for current_user
    current_user.acid.contribute_currency 10, :imagine, 'daily_bonus'
    "coins10"
  end

  def self.three_days_for current_user
    current_user.acid.contribute_currency 25, :imagine, 'daily_bonus'
    "coins25"
  end

  def self.four_days_for current_user
    current_user.acid.contribute_currency 50, :imagine, 'daily_bonus'
    "coins50"
  end

  def self.random_bonus current_user
    case rand(3)
    when 0 then self.vip current_user
    when 1 then self.teleport current_user
    when 2 then self.coin current_user
    end
  end
  
  private

  def self.star current_user
    current_user.acid.contribute_currency 1, :real, 'daily_bonus'
    "stars1"
  end

  def self.vip current_user
    StoreHelper.give_bottle! current_user, Weapon.where(_id: 27).first # vip
    "vip1"
  end

  def self.teleport current_user
    StoreHelper.give_skill! current_user, Weapon.where(_id: 2).first, charge: 50 # teleport
    "teleport50"
  end

  def self.coin current_user
    current_user.acid.contribute_currency 100, :imagine, 'daily_bonus'
    "coins100"
  end
end
