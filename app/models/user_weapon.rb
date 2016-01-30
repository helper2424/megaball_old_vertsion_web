class UserWeapon < Weapon

  auto_increment :_id, seed: 1000
  field :user_id, type: Integer
  field :active, type: Boolean, default: false # using in game?
  field :activate_time, type: Integer, default: ->{ Time.now.to_i } # time when was activated current charge
  field :update_time, type: Integer, default: 0 # time when model was updated
  field :mana_required, type: Integer, default: 0
  field :origin, type: Integer, default: nil
	
  validate :active_count
  validate :charge_count
  validates_presence_of :user_id

  index({"user_id" => 1})
  index update_time: 1
  index user_id: 1, light_vip: 1

  def not_active?
    !self.active
  end

  def charge_count
    return unless active
    if wasting and (charge.nil? or charge == 0)
      errors.add :zero_charged, I18n.t(:zero_charged)
    end
  end

  def try_to_activate
    info = count_for_current_user self.type
    if info[:max] <= 0 or info[:count] < info[:max]
      self.active = true
    end
  end

  def active_count
    return unless active
    info = count_for_current_user type
    if info[:max] > 0 and info[:count] >= info[:max]
      f = info[:weapons].last
      f.active = false
      f.save
    end
  end

  def overdue?
    self.type == 5 and # only bottles
    (self.activate_time * 1000 +
      self.charge * self.action_time) < 
        Time.now.to_i * 1000
  end

  def actual_charges
    overdue? ? 0 : self.charge
  end

  def self.max_for_type(type, vip)
    case type
    when 0 then 2#(2 + (vip ? 1 : 0))
    when 1 then 1
    when 2 then 1
    when 3 then 1
    when 4 then 2
    when 6 then 1
    else 0
    end
  end

  def self.check_active(user)
    w = UserWeapon.where(user_id: user._id, type: 0, active: true).first
    if not w.nil?
      w.active_count
    end
  end

  def self.each_overdue(user)
    UserWeapon
      .where(user_id: user._id)
      .each { |x| yield x if x.overdue? }
  end

  scope :zero_charged, ->(user) {
    where(
      user_id: user._id, 
      wasting: true, 
      recharging: false, 
      charge: 0
    )
  }

  attr_accessible :active
  attr_accessible :origin

  def count_for_current_user type
    weapons = UserWeapon.where(user_id: user_id, type: type, active: true)
                        .ne(_id: self._id)
                        .order_by([:update_time, :asc])
                        .entries
    vip =  UserWeapon.where(user_id: user_id, light_vip: true).count > 0
    max = UserWeapon.max_for_type(type, vip)
    { count: weapons.count, max: max, weapons: weapons }
  end
end
