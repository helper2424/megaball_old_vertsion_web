class Weapon
  include Mongoid::Document

  field :_id, type: Integer, default: 0
  field :title, localize: true, default: ""
  field :description, localize: true, default: ""
  field :texture, type: String, default: ""
  field :mul_params, type: Hash, default: {}
  field :sum_params, type: Hash, default: {}
  field :pump_params, type: Hash, default: {}
  field :type, type: Integer, default: 0 # 0 - weapon, 1 - hat, 2 - shirt, 3 - shoes, 4 - amulet, 5 - bottle, 6 - pants
  field :instant_use, type: Boolean, default: false # use it as you buy it
  field :last_use_time, type: Integer, default: 0 # last use Unix timestamp
  field :recharging, type: Boolean, default: true # can recharge, or you lose it on zero charge!
  field :wasting, type: Boolean, default: true # waste one charge per use, or you have it forever!
  field :charge, type: Integer, default: 1 # charge amount
  field :action_interval, type: Integer, default: 10000 # time interval between usage of this weapon (cooldown)
  field :action_time, type: Integer, default: 0 # one charge acting duration in mls. 0 ms = action while it's active or once action
  field :action, type: Integer, default: 0 # wut action? teleport? power up? who nose... (WeaponModel.java)
  field :light_vip, type: Boolean, default: false # light up vip sign at the top
  field :waste_per_match, type: Boolean, default: false # if true, then 1 charge delete by 1 match (without time dependency)
  field :mana_required, type: Integer, default: 0

  attr_accessible :_id, :title, :description, :texture, :mul_params, :sum_params, :pump_params, :type, :instant_use, 
    :last_use_time, :recharging, :wasting, :charge, :action_interval, :action_time, :action, :light_vip, :waste_per_match, 
    :mana_required

end
