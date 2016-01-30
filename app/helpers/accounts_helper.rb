module AccountsHelper

  def self.check_for_upgrade! user
    provider = user.oauth_providers
    provider = provider[0] unless provider.nil?
    return if provider.nil?

    db = Mongoid::Sessions.with_name(:megaball1)
    old_user = db[:users].find({ 
      :'oauth_providers.provider' => provider.provider,
      :'oauth_providers.uid' => provider.uid
    }).first
    return if old_user.nil?

    # clubs
    club_user = db[:club_users].find({ uid: old_user['_id'] }).first
    if !club_user.nil? && !Club.find(club_user['cid']).nil?
      ClubUser.create({ 
        uid: user.id, 
        cid: club_user['cid'], 
        role: club_user['role'] 
      })
    end

    # weapons
    mana = 0
    UserWeapon.where(user_id: user.id).delete_all
    db[:weapons].find({ 
      _type: 'UserWeapon', 
      user_id: old_user['_id'] 
    }).entries.each do |weapon|
      data = weapon.as_json(except: [
        '_id', '_type', 'user_id'
      ])

      if data['type'] == 0
        data['wasting'] = false
        data['waste_per_match'] = false
        data['mana_required'] = case data['action'].to_i
                                when 1 then 2
                                when 2 then 3
                                when 3 then 3
                                when 4 then 4
                                when 5 then 10
                                when 6 then 7
                                when 7 then 7
                                when 8 then 4
                                else 0
                                end
        mana += data['charge'] * 3
      elsif [1, 2, 3, 4, 6].include?(data['type'])
        data['wasting'] = true
        data['waste_per_match'] = true
        data['charge'] = 1000
      end

      if data['origin'] == 19
        data['wasting'] = false
        data['charge'] = 1
        data['waste_per_match'] = false
      end

      w = UserWeapon.new(data)
      w.user_id = user.id
      w.save
    end
    mana = mana + 200
    user.set(:mana, mana)

    # user stats
    old_user.as_json(except: [
      '_id', 'oauth_providers', 'account_version',
      'user_collection', 'user_control',
      'add_stars', 'add_coins', 'email',
      'encrypted_password', 'name', 'last_accessed',
      'last_game_result_id', 'token', 'add_imagine',
      'locale', 'zone', 'energy', 'first_time', 'stage',
      'user_achievement', 'user_control'
    ]).each do |key, value|
      user[key.to_sym] = value
    end
    user[:locale] = 'ru'
    user[:zone] = 'russian'
    user[:coins] = 10 if user[:coins] < 10
    user[:roulette_tickets] = 1

    # achievements
    unless old_user['user_achievement'].nil?
      user.user_achievement = old_user['user_achievement'].map do |data|
        UserAchievement.new data.as_json(except: [:_id])
      end
    end

    # money
    AcidUser.transaction do
      acid = user.acid
      acid.lock!
      acid.real_balance = old_user['stars']
      acid.imagine_balance = old_user['coins']
      acid.save!
    end

    user.save!
    db[:users].find({ _id: old_user['_id'] })
              .update({ '$set' => { account_version: 2 } })
  end

end
