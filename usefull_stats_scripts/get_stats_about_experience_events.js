var resultArray = [];
//Количество игр
var currentTimestamp = (new Date().getTime() / 1000) - 86400;

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
			if(ugr_el.player_game_result != undefined && ugr_el.player_game_result && ugr_el.player_game_result.stats_entries != undefined)
				ugr_el.player_game_result.stats_entries.forEach(function(stat, st_index, st_array){
					emit(stat.entry_name, 1);
				});
			
		})
	});
};

var reduce = function(key, values){return Array.sum(values)};

result = db.game_results.mapReduce(map, reduce, {query:{timestamp:{$gte:currentTimestamp}}, out:{inline:1}})
result.results.forEach(function(el){
	resultArray.push(el._id + " " + el.value);
});

resultArray.forEach(function(el, index, ar){printjson(el)});