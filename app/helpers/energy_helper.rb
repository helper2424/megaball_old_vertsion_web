module EnergyHelper
  def check_energy!
    user = current_user
    energy = user.energy
    now = Time.now
    max_energy = UserDefault.first.energy_max_restore

    if energy < max_energy
      if !user.last_energy_update.nil?
        diff = (now - user.last_energy_update) / 60
        
        restored_energy = (diff.floor * user.energy_restore_factor)

        if user.energy + restored_energy > max_energy
          user.set_energy max_energy
        else
          user.set_energy user.energy + restored_energy
        end

      else
        restored_energy = max_energy - user.energy
        restored_energy = 0 if restored_energy < 0
        user.set_energy user.energy + restored_energy
      end

      if user.energy != energy || user.last_energy_update.nil?
        user.last_energy_update = now
        user.save
      end
    else
      user.last_energy_update = now
      user.save
    end
  end

  def get_volcano_energy
    user = current_user
    energy = user.energy
    now = Time.now
    max_energy = UserDefault.first.energy_max_restore  
    
    if !user.last_volcano_update.nil?
      diff = (now - user.last_volcano_update).to_i / 60
      
      restored_energy = (diff.floor * user.energy_restore_factor)
      restored_energy = calc_energy(restored_energy, user.energy_after_volcano, user.level)
      restored_energy = max_energy if restored_energy > max_energy      
    else
      restored_energy = max_energy
      restored_energy = max_energy if restored_energy < 0
    end  

    restored_energy
  end  

  def check_energy_requests!
    req = current_user.energy_request_friend.first
    unless req.nil?
      res = req.receiver
      res.set_energy(res.energy + UserDefault.first.energy_per_friend)
      res.save
    end
    current_user.energy_request_friend.delete_all
  end

  def calc_energy(restored_energy, user_energy, user_level)
    level_coefficient = user_level <= 5 ? 2 : 1
    restored_energy *= level_coefficient
    total_energy = restored_energy + user_energy
    energy = 0

    if user_energy < 100
      energy += ((total_energy > 100 ? 100 : total_energy) - user_energy)
      total_energy = user_energy + energy + (total_energy > 100 ? total_energy - 100 : 0) 
    end

    if user_energy < 175
      energy += (((total_energy > 175 ? 175 : total_energy) - user_energy - energy) * 2 / 3)
      total_energy = user_energy + energy + (total_energy > 175 ? total_energy - 175 : 0) 
    end
 
    if user_energy < 425
      energy += (((total_energy > 425 ? 425 : total_energy) - user_energy - energy) * 2 / 5)
      total_energy = user_energy + energy + (total_energy > 425 ? total_energy - 425 : 0) 
    end

    energy += ((total_energy - user_energy - energy) * 2 / 10)

    return energy
  end
end
