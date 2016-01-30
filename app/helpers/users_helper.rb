module UsersHelper

  def self.fresh_user info={}
    user = User.new info
    user.category = "ABC"[rand(3)]
    user.save!
    self.give_default_weapons user
    user
  end

  def self.give_default_weapons user
    active_left = 2
    Weapon.where(:_id.in => MEGABALL_CONFIG["default_weapons"])
          .each do |weapon|
            user_weapon = UserWeapon.new 
            user_weapon.title = weapon.title
            user_weapon.wasting = weapon.wasting
            user_weapon.mana_required = weapon.mana_required
            user_weapon.description = weapon.description
            user_weapon.charge = weapon.charge
            user_weapon.texture = weapon.texture
            user_weapon.action_interval = weapon.action_interval
            user_weapon.recharging = weapon.recharging
            user_weapon.action_time = weapon.action_time
            user_weapon.action = weapon.action
            user_weapon.origin = weapon._id
            user_weapon.user_id = user._id
            user_weapon.active = (active_left > 0)
            user_weapon.save!
            active_left -= 1
          end
  end

  def self.give_free_weapons user, weapons_ids
    active_left = 2
    Weapon.where(:_id.in => weapons_ids)
          .each do |weapon|
            user_weapon = UserWeapon.new 
            user_weapon.title = weapon.title
            user_weapon.wasting = weapon.wasting
            user_weapon.mana_required = weapon.mana_required
            user_weapon.description = weapon.description
            user_weapon.charge = weapon.charge
            user_weapon.texture = weapon.texture
            user_weapon.action_interval = weapon.action_interval
            user_weapon.recharging = weapon.recharging
            user_weapon.action_time = weapon.action_time
            user_weapon.action = weapon.action
            user_weapon.origin = weapon._id
            user_weapon.user_id = user._id
            user_weapon.active = (active_left > 0)
            user_weapon.pump_params = weapon.pump_params
            user_weapon.waste_per_match = weapon.waste_per_match
            user_weapon.type = weapon.type
            user_weapon.save!
            active_left -= 1
          end
  end

  def self.pump_points user, weapons
    weapons.reject(&:not_active?).each do |weapon|
      weapon.pump_params.each do |key, value|
        user[key] += value
      end
    end
  end

  def self.combined_info(source)
    save_user = false
    @user = source
    

    # Join weapons
    user = @user.as_json
    user['weapons'] = UserWeapon.where(user_id: @user._id).order_by([:update_time, :asc])

    # Clothes
    self.pump_points user, user['weapons']

    # OAuth providers
    user[:oauth_providers] = []
    @user.oauth_providers.each { |p| user[:oauth_providers] << p.as_json }

    # Room
    unless @user.room.nil?
      user[:room] = @user.room.as_json
      user[:room][:password] = @user.room.password
    end

    # Room
    unless @user.filters_enabled
      user[:room_id] = @user.room_id 
    end

    # Score
    user[:place] = UsersHelper.user_place @user 

    user[:profile_url] = @user.profile_url

    # Save user
    @user.save if save_user

    user
  end

  def self.user_place(user, by = 'rating')
    by = by.to_sym
    field = user.send by
    #User.where(by => {:$gt => field}).group_by{ |x| x.send by }.count + 1
    User.where(by.gt => field).distinct(by).count + 1
  end

  def self.update_stats_entries_fields__ user_ids, vk_app
    res = vk_app.vk_call 'users.get', {user_ids:user_ids, fields: ['bdate', 'sex']}
    res.each {|u|
        sex = if u['sex'] == 2 then 'male' \
              elsif u['sex'] == 1 then 'female' \
              else 'unknown' end
        bdate = u['bdate'] || 'unknown'

        puts bdate
        update_user = User.where("oauth_providers.provider" => 'vkontakte').and("oauth_providers.uid" => u['uid'].to_s).first 
        update_user.update_attributes sex: sex, bdate: bdate
        StatEntry.where("info.user_id" => update_user._id).update_all('info.sex' => sex, 'info.bdate' => bdate)
    }
  end 

  #get improve border for pumping ticks 
  def self.get_improve_border current_param_value
    improve_border = 1

    defaults = UserDefault.first

    return improve_border if defaults.nil?
    
    if !defaults.pumping_border.nil? and !defaults.pumping_border.empty?
      if defaults.pumping_border[current_param_value].nil?
        improve_border = defaults.pumping_border.last
      else
        improve_border = defaults.pumping_border[current_param_value]
      end
    end
    improve_border
  end

  #temp method for update stats fields
  def self.update_stats_entries_fields
    vk_app = VK::Application.new app_id: MEGABALL_IFRAME_CONFIG['vk']['id'], app_secret: MEGABALL_IFRAME_CONFIG['vk']['secret_key']

    user_ids = []
    User.where("oauth_providers.provider" => "vkontakte").each { |u|
      user_ids << u.oauth_providers.first.uid

      if user_ids.count >= 1000
        self.update_stats_entries_fields__ user_ids, vk_app
        user_ids = []
      end
    }

    self.update_stats_entries_fields__ user_ids, vk_app unless user_ids.empty?

    #update payment data
    StatEntry.where(event: :payment).each {|e|
      cur = e.info['item']

      custom = {}

      if cur == :real
        if e.info['quantity'] == 3
          custom = {bonus: 0, amount: 3}
        elsif e.info['quantity'] == 1
          custom = {bonus: 0, amount: 1}
        elsif e.info['quantity'] == 5
          custom = {bonus: 0, amount: 5}
        elsif e.info['quantity'] == 11
          custom = {bonus: 1, amount: 10}
        elsif e.info['quantity'] == 22
          custom = {bonus: 2, amount: 20}
        elsif e.info['quantity'] == 55
          custom = {bonus: 5, amount: 50}
        elsif e.info['quantity'] == 110
          custom = {bonus: 10, amount: 100}
        elsif e.info['quantity'] == 220
          custom = {bonus: 20, amount: 200}
        end
      elsif cur == :imagine
        if e.info['quantity'] == 50
          custom = {bonus: 0, amount: 50}
        elsif e.info['quantity'] == 160
          custom = {bonus: 10, amount: 150}
        elsif e.info['quantity'] == 275
          custom = {bonus: 25, amount: 250}
        elsif e.info['quantity'] == 550
          custom = {bonus: 50, amount: 500}
        elsif e.info['quantity'] == 1120
          custom = {bonus: 120, amount: 1000}
        elsif e.info['quantity'] == 2900
          custom = {bonus: 400, amount: 2500}
        elsif e.info['quantity'] == 5900
          custom = {bonus: 900, amount: 5000}
        elsif e.info['quantity'] == 7000 
          custom = {bonus: 1000, amount: 6000}
        end
      end

      e.info['custom'] = custom
      e.save
    }

  end
end
