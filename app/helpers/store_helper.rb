require 'set'

class UserItemManager
  include ErrorsHelper
  
  attr_accessor :user, :errors

  def initialize user
    @user = user
    @errors = []
    @models_to_save = Set.new [user]
  end

  def add_item item
    @errors = []
    @models_to_save = Set.new [user]

    contents = item.item_contents
    contents = [item.item_contents.sample] if item.random

    contents.each do |cont|
      method = "add_#{cont.type}".to_sym
      if self.respond_to? method
        self.send method, cont
      else
        queue_error :unknown_type, type: cont.type, method: method
      end
    end

    save
  end

  def save
    if @errors.empty?
      @models_to_save.each { |model| model.save }
      []
    else
      @errors
    end
  end

  def queue_error msg = :unspecified, data = {}
    @errors << error(msg, data)
  end

  def queue_model_save model
    @models_to_save << model
  end

  def add_hair cont
    if user.avail_hair.include? cont.content
      queue_error :already_bought
    else
      count = user.get_dynamic_stat(:bought_faces) || 0
      user.set_dynamic_stat(:bought_faces, count + 1)
      user.avail_hair += [cont.content]
    end
  end

  def add_eye cont
    if user.avail_eye.include? cont.content
      queue_error :already_bought
    else
      count = user.get_dynamic_stat(:bought_faces) || 0
      user.set_dynamic_stat(:bought_faces, count + 1)
     user.avail_eye << cont.content
    end
  end

  def add_mouth cont
    if user.avail_mouth.include? cont.content
      queue_error :already_bought
    else
      count = user.get_dynamic_stat(:bought_faces) || 0
      user.set_dynamic_stat(:bought_faces, count + 1)
      user.avail_mouth << cont.content
    end
  end


  def add_reset_points cont
    ud = UserDefault.first 

    user.points += user.leg_length_buffer + user.move_force_buffer + user.kick_power_buffer + 
      user.mana_top_buffer + user.nitro_speed_buffer + get_points_from_pump(user.kick_power, ud) +
      get_points_from_pump(user.move_force, ud) + get_points_from_pump(user.leg_length, ud) + 
      get_points_from_pump(user.nitro_speed, ud) + get_points_from_pump(user.mana_top, ud) +
      user.perk_nitro_repair_latency + user.perk_nitro_repair_speed  + user.perk_nitro_dribbling_user + 
      user.perk_super_kick_repair_enemy_kick_ball + user.perk_super_kick_repair_enemy_kick_player + 
      user.perk_super_kick_slowdown_enemy + user.perk_mana_repair_speed + user.perk_mana_chance_to_return +
      user.perk_mana_start_with_mana
    
    user.kick_power = 0
    user.move_force = 0
    user.leg_length = 0
    user.nitro_speed = 0
    user.mana_top = 0
    user.kick_power_buffer = 0
    user.move_force_buffer = 0
    user.leg_length_buffer = 0
    user.nitro_speed_buffer = 0
    user.mana_top_buffer = 0

    user.perk_nitro_repair_latency = 0
    user.perk_nitro_repair_speed = 0
    user.perk_nitro_dribbling_user = 0
    user.perk_super_kick_repair_enemy_kick_ball = 0
    user.perk_super_kick_repair_enemy_kick_player = 0
    user.perk_super_kick_slowdown_enemy = 0
    user.perk_mana_repair_speed = 0
    user.perk_mana_chance_to_return = 0
    user.perk_mana_start_with_mana = 0
  end

  def add_point cont
    user.points += cont.content
  end

  def add_weapon cont
    weapon = Weapon.where(_id: cont.content)
    return queue_error :unknown_weapon, weapon: cont.content if weapon.count == 0
    weapon = weapon.first
    charges = cont.count * weapon.charge

    user_weapon = UserWeapon.where(user_id: user.id, origin: weapon.id)
    return queue_error :already_bought if user_weapon.count != 0 and not weapon.wasting
    user_weapon = user_weapon.count == 0 \
                  ? UserWeapon.new(charge: 0) \
                  : user_weapon.first

    weapon.as_json(except: [:_id, :charge, :activate_time])
          .each do |key, value|
      user_weapon[key] = value
    end
    user_weapon.activate_time = Time.now.to_i
    user_weapon.update_time = Time.now.to_i
    user_weapon.user_id = user.id
    user_weapon.origin = weapon.id
    user_weapon.active = true if weapon.instant_use
    user_weapon.charge = user_weapon.overdue? \
                       ? charges \
                       : (user_weapon.charge + charges)
    user_weapon.try_to_activate

    if weapon.light_vip
      user.experience += user.loss_of_experience_without_vip if !user.loss_of_experience_without_vip.nil? and user.loss_of_experience_without_vip > 0
      user.loss_of_experience_without_vip = 0
      user.inc_dynamic_stat :bought_vips
      user.inc_dynamic_stat :bought_gold_vips if charges >= 30
    end

    queue_model_save user_weapon
  end

  def add_energy cont
    user.energy += cont.content
    {}
  end

  def add_mana cont
    if user.mana < user.mana_max
      user.mana += cont.content
      user.mana = user.mana_max if user.mana > user.mana_max
    end
    {}
  end

  def add_overmana cont
    user.mana += cont.content
    {}
  end

  def add_exclusive cont
    user.exclusive_count += 1
    {}
  end

  def add_roulette_ticket cont
    user.roulette_tickets += cont.content.to_i
    {}
  end

  def add_reset cont
    template = User.new
    MEGABALL_CONFIG['user_fields_to_reset'].each do |field|
      user.send("#{field}=".to_sym, template.send(field.to_sym))
    end
    UserWeapon.where(user_id: user.id).delete_all
    UsersHelper.give_default_weapons(user)
    user.mana = user.mana_max
    user.energy = template.energy
    {}
  end

protected 
  
  def get_points_from_pump param_value, user_defaults
    pumping_border = user_defaults.pumping_border
    res = 0

    if !pumping_border.nil? and !pumping_border.empty?
      param_value.downto(1) {|v| 
        puts "#{param_value} + #{v} !!!"
        if v >= pumping_border.size
          res += pumping_border.last
        else
          res += pumping_border[v-1]
        end
      }
    end

    puts "#{param_value} result #{res} "
    res
  end
end

module StoreHelper
  def user_items user
    UserItemManager.new(user)
  end

  def add_item user, item
    user_items(user).add_item(item)
  end
end
