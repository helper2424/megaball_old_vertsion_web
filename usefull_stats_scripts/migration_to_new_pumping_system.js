function get_points_from_pump(param_value){
	var res = 0;
	var pumping_border = db.user_defaults.findOne().pumping_border;
	var buf = param_value;

	while(buf > 0)
		res += pumping_border[--buf];

	return res;
}

function getInt(val){
	var res = 0;

	if(val != undefined && val != NaN)
		res = parseInt(val);

	return res;
}

db.users.find().forEach(function(u){
	var new_points = getInt(u.points);

	new_points += getInt(u.leg_length_buffer);
	new_points += getInt(u.kick_power_buffer);
	new_points += getInt(u.move_force_buffer);

	new_points += getInt(get_points_from_pump(u.leg_length));
	new_points += getInt(get_points_from_pump(u.kick_power));
	new_points += getInt(get_points_from_pump(u.move_force));

	db.users.update({_id: u._id}, {$set:{points: new_points, leg_length: 0, move_force: 0, kick_power: 0,leg_length_buffer:0,
  		kick_power_buffer:0, move_force_buffer: 0}});
});

db.user_defaults.update({},{$set:{ mana_top_max: 300, nitro_spend_speed: 20, nitro_restore_speed: 3, nitro_force_min: 450,
	nitro_force_max: 550,mana_top_min: 50, nitro_repair_latency: 2, nitro_repair_zero_latency: 0.5, 
	nitro_max: 100, super_kick_power_steps: 100, super_kick_restore_factor: 10, mana_repair_factor: 0.1,  pumping_perk_borders: {
    perk_nitro_repair_latency : {param: "nitro_speed", borders: [5, 20, 35]}, 
    perk_nitro_repair_speed : {param: "nitro_speed", borders: [10, 25, 40]}, 
    perk_nitro_dribbling_user : {param: "nitro_speed", borders: [15, 30, 45]}, 
    perk_super_kick_repair_enemy_kick_ball : {param: "kick_power", borders: [5, 20, 35]}, 
    perk_super_kick_repair_enemy_kick_player : {param: "kick_power", borders: [10, 25, 40]}, 
    perk_super_kick_slowdown_enemy : {param: "kick_power", borders: [15, 30, 45]}, 
    perk_mana_repair_speed : {param: "mana_top", borders: [5, 20, 35]}, 
    perk_mana_chance_to_return : {param: "mana_top", borders: [10, 25, 40]}, 
    perk_mana_start_with_mana : {param: "mana_top", borders: [15, 30, 45]}
  }
}});