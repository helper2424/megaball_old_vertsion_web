module ManaHelper
  def check_vip_mana!
    user = current_user
    mana = user.mana
    now = Time.now
    restore_factor = mana_restore_factor_for user

    if user.mana > user.mana_max
      user.last_mana_update = now
      user.save
      return
    end

    if user.last_mana_update.nil?
      user.mana = user.mana_max
    elsif restore_factor > 0
      diff = (now - user.last_mana_update) / 60
      user.mana = user.mana + (diff.floor * restore_factor)
      user.mana = user.mana_max if user.mana > user.mana_max
    end

    if user.mana != mana || user.last_mana_update.nil?
      user.last_mana_update = now
      user.save
    end
  end

  def check_mana!
    user = current_user
    
    if user.mana > user.mana_max
      user.last_daily_mana = Time.now.to_i
      user.save
      return
    end

    if user.last_daily_mana < Time.now.beginning_of_day.to_i
      user.last_daily_mana = Time.now.to_i
      user.mana += UserDefault.first.mana_daily
      user.mana = user.mana_max if user.mana > user.mana_max
      user.save
    end
  end

  def mana_restore_factor_for user
    vips = UserWeapon.where(user_id: user.id, light_vip: true)
    if vips.count > 0
      charges = vips.map(&:actual_charges).sum
      last_factor = 0
      MEGABALL_CONFIG['mana_restore_factors'].each do |required, factor|
        return last_factor if required > charges
        last_factor = factor
      end
      last_factor
    else
      0
    end
  end 
end
