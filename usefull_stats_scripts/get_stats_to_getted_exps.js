var resultArray = [];
//Количество игр
var currentTimestamp = (new Date().getTime() / 1000) - 3*86400;

var map = function(){emit(1, 1)};
var reduce = function(key, values){return Array.sum(values)};

result = db.game_results.mapReduce(map, reduce, {query:{timestamp:{$gte:currentTimestamp}}, out:{inline:1}})
resultArray.push("Количество игр: " + result.results[0].value);

//Количество игравших
var map = function(){
	this.team_game_results.forEach(function(element, index, array){
		element.user_game_results.forEach(function(ugr_el, ugr_i, ugr_i){
			emit(ugr_el._id, 1);
		})
	});
};

var reduce = function(key, values){return 1};

result = db.game_results.mapReduce(map, reduce, {query:{timestamp:{$gte:currentTimestamp}}, out:{inline:1}})
resultArray.push("Количество игроков : " +  result.counts.output);

//Стата по событиям выдачи опыта
var map = function(){
	this.team_game_results.forEach(function(element, index, array){
		element.user_game_results.forEach(function(ugr_el, ugr_i, ugr_i){
			if(ugr_el.player_game_result != undefined && ugr_el.player_game_result && ugr_el.experience >0 && ugr_el.player_game_result.stats_entries != undefined){
				var teoretical_exp_in_new_system = 0;

				ugr_el.player_game_result.stats_entries.forEach(function(stat, st_index, st_array){
					switch(stat.entry_name){
						case "win":
							teoretical_exp_in_new_system += 1400;
							break;
    
						case "draw":
							teoretical_exp_in_new_system += 1000;
							break;
						case "fail":
							teoretical_exp_in_new_system += 700;
							break;
						case "will_win":
							teoretical_exp_in_new_system += 700;
							break;
						case "last_second_win":
							teoretical_exp_in_new_system += 700;
							break;
						case  "last_second_draw":
							teoretical_exp_in_new_system += 500;
							break;
						case "last_second_goal":
							teoretical_exp_in_new_system += 200;
							break;
						case "technical_win":
							teoretical_exp_in_new_system += 500;
							break;
						case "prestigious_goal":
							teoretical_exp_in_new_system += 500;
							break;
						case "strong_victory":
							teoretical_exp_in_new_system += 500;
							break;
						case "win_after_several_fails":
							teoretical_exp_in_new_system += 1000;
							break;
						case "win_after_fail":
							teoretical_exp_in_new_system += 750;
							break;
						case "play_alone":
							teoretical_exp_in_new_system += 1000;
							break;
						case "several_wins":
							teoretical_exp_in_new_system += 500;
							break;
						case "head_trick":
							teoretical_exp_in_new_system += 700;
							break;
						case "head_trick_minor":
							teoretical_exp_in_new_system += 1050;
							break;
						case "first_goal":
							teoretical_exp_in_new_system += 200;
							break;
						case "best_player":
							teoretical_exp_in_new_system += 400;
							break;
						case "best_forward":
							teoretical_exp_in_new_system += 200;
							break;
						case "best_goalkeeper":
							teoretical_exp_in_new_system += 200;
							break;
						case "best_goal_passer":
							teoretical_exp_in_new_system += 200;
							break;
						case "rod_hits":
							teoretical_exp_in_new_system += 200;
							break;
						case "rod_hits_minor":
							teoretical_exp_in_new_system += 300;
							break;
						case "pass":
							teoretical_exp_in_new_system += 50;
							break;
						case "pass_minor":
							teoretical_exp_in_new_system += 75;
							break;
						case "gate_save":
							teoretical_exp_in_new_system += 200;
							break;
						case "gate_save_minor":
							teoretical_exp_in_new_system += 300;
							break;
						case "several_related_goals":
							teoretical_exp_in_new_system += 400;
							break;
						case "ball_out_from_penalty_area":
							
							break;
						case "ball_out_from_penalty_area_minor":
							
							break;
						case "goal_pass":
							teoretical_exp_in_new_system += 200;
							break;
						case "goal_pass_minor":
							teoretical_exp_in_new_system += 300;
							break;
						case "revenge":
							teoretical_exp_in_new_system += 500;
							break;
						case "goal":
							teoretical_exp_in_new_system += 200;
							break;
						case "goal_minor":
							teoretical_exp_in_new_system += 300;
							break;
					}
				});

				var additionalVal = 0;

				if(ugr_el.player_game_result.has_vip)
					additionalVal += parseInt(teoretical_exp_in_new_system * ugr_el.player_game_result.vip_modifier);

				if(ugr_el.player_game_result.is_first_day_win)
					additionalVal += parseInt(teoretical_exp_in_new_system * ugr_el.player_game_result.first_day_win_modifier);

				teoretical_exp_in_new_system += additionalVal;

				if(teoretical_exp_in_new_system > 10000)
				{
					printjson("WTFFF??? " + this._id);
				}

				emit(Math.ceil(teoretical_exp_in_new_system / 500), 1);
			}
		})
	});
};

var reduce = function(key, values){return Array.sum(values)};

result = db.game_results.mapReduce(map, reduce, {query:{timestamp:{$gte:currentTimestamp}}, out:{inline:1}})
result.results.forEach(function(el){
	resultArray.push(500* el._id + " " + el.value);
});

resultArray.forEach(function(el, index, ar){printjson(el)});


//GET FUCKED CHITERS
//Стата по событиям выдачи опыта
var map = function(){
	var that_id = this._id;
	this.team_game_results.forEach(function(element, index, array){
		element.user_game_results.forEach(function(ugr_el, ugr_i, ugr_i){
			if(ugr_el.player_game_result != undefined && ugr_el.player_game_result && ugr_el.experience >0 && ugr_el.player_game_result.stats_entries != undefined){
				var teoretical_exp_in_new_system = 0;

				ugr_el.player_game_result.stats_entries.forEach(function(stat, st_index, st_array){
					switch(stat.entry_name){
						case "win":
							teoretical_exp_in_new_system += 1400;
							break;
    
						case "draw":
							teoretical_exp_in_new_system += 1000;
							break;
						case "fail":
							teoretical_exp_in_new_system += 700;
							break;
						case "will_win":
							teoretical_exp_in_new_system += 700;
							break;
						case "last_second_win":
							teoretical_exp_in_new_system += 700;
							break;
						case  "last_second_draw":
							teoretical_exp_in_new_system += 500;
							break;
						case "last_second_goal":
							teoretical_exp_in_new_system += 200;
							break;
						case "technical_win":
							teoretical_exp_in_new_system += 500;
							break;
						case "prestigious_goal":
							teoretical_exp_in_new_system += 500;
							break;
						case "strong_victory":
							teoretical_exp_in_new_system += 500;
							break;
						case "win_after_several_fails":
							teoretical_exp_in_new_system += 1000;
							break;
						case "win_after_fail":
							teoretical_exp_in_new_system += 750;
							break;
						case "play_alone":
							teoretical_exp_in_new_system += 1000;
							break;
						case "several_wins":
							teoretical_exp_in_new_system += 500;
							break;
						case "head_trick":
							teoretical_exp_in_new_system += 700;
							break;
						case "head_trick_minor":
							teoretical_exp_in_new_system += 1050;
							break;
						case "first_goal":
							teoretical_exp_in_new_system += 200;
							break;
						case "best_player":
							teoretical_exp_in_new_system += 400;
							break;
						case "best_forward":
							teoretical_exp_in_new_system += 200;
							break;
						case "best_goalkeeper":
							teoretical_exp_in_new_system += 200;
							break;
						case "best_goal_passer":
							teoretical_exp_in_new_system += 200;
							break;
						case "rod_hits":
							teoretical_exp_in_new_system += 200;
							break;
						case "rod_hits_minor":
							teoretical_exp_in_new_system += 300;
							break;
						case "pass":
							teoretical_exp_in_new_system += 50;
							break;
						case "pass_minor":
							teoretical_exp_in_new_system += 75;
							break;
						case "gate_save":
							teoretical_exp_in_new_system += 200;
							break;
						case "gate_save_minor":
							teoretical_exp_in_new_system += 300;
							break;
						case "several_related_goals":
							teoretical_exp_in_new_system += 400;
							break;
						case "ball_out_from_penalty_area":
							
							break;
						case "ball_out_from_penalty_area_minor":
							
							break;
						case "goal_pass":
							teoretical_exp_in_new_system += 200;
							break;
						case "goal_pass_minor":
							teoretical_exp_in_new_system += 300;
							break;
						case "revenge":
							teoretical_exp_in_new_system += 500;
							break;
						case "goal":
							teoretical_exp_in_new_system += 200;
							break;
						case "goal_minor":
							teoretical_exp_in_new_system += 300;
							break;
					}
				});

				var additionalVal = 0;

				if(ugr_el.player_game_result.has_vip)
					additionalVal += parseInt(teoretical_exp_in_new_system * ugr_el.player_game_result.vip_modifier);

				if(ugr_el.player_game_result.is_first_day_win)
					additionalVal += parseInt(teoretical_exp_in_new_system * ugr_el.player_game_result.first_day_win_modifier);

				teoretical_exp_in_new_system += additionalVal;

				if(teoretical_exp_in_new_system > 17000)
					emit(that_id, that_id);
			}
		})
	});
};

var chiters_game = [];
var reduce = function(key, values){return 1};
result = db.game_results.mapReduce(map, reduce, {query:{timestamp:{$gte:currentTimestamp}}, out:{inline:1}});
result.results.forEach(function(el){
	printjson(el);
});