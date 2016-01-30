module PumpingHelper
	def available_perk_ticks param_name, user, defaults
		res = 0
		perk_borders = defaults[:pumping_perk_borders]

		if perk_borders.is_a?(Hash) and perk_borders.stringify_keys! and perk_borders[param_name].is_a?(Hash)
			perk_borders = perk_borders[param_name].stringify_keys

			if !perk_borders['param'].nil? and !user[perk_borders['param'].to_s].nil? and perk_borders['borders'].is_a? Array and !perk_borders['borders'].empty?
				available_by_pump_value = 0
				pump_value = user[perk_borders['param']].to_i

				perk_borders['borders'].each {|b|	available_by_pump_value += 1 if pump_value >= b	}

				puts available_by_pump_value
				res = available_by_pump_value - user[param_name].to_i
				res = 0 if res < 0
			end
		end

		res
	end

	def improve_perk_param param_name, user, defaults, errors
    avavailable_ticks = available_perk_ticks param_name, user, defaults
    if avavailable_ticks > 0
      user[param_name] += 1
      user.points -= 1

      user.save
    else
      errors[:points] = 'does_not_have_available_ticks'
    end    
  end

  def improve_pump_param param_name, user, defaults, errors
    if user[param_name] < defaults.pumping_ticks
      user[param_name + '_buffer'] += 1
      user.points -= 1

      improve_border = UsersHelper.get_improve_border user[param_name]

      if user[param_name + '_buffer'] >= improve_border
        user[param_name + '_buffer'] -= improve_border
        user[param_name] += 1
      end

      user.save
    else
      errors[:points] = 'points_max_already'
    end
  end
end