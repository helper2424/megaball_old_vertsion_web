var is_release = false;

//Убираем все очки прокачки
function get_user_level(u, levels){var counter = 0;for(i = 0; i<levels.length; i++){ if(u.experience >= levels[i]) counter++; else return counter; } return counter;}

var old_levels = [0, 300, 5000, 30000, 70000, 130000, 250000, 500000, 750000, 1000000, 1250000, 1500000, 1750000, 2000000, 2500000, 3000000, 3500000, 4000000, 4500000, 5000000 ];
var buf_levels = [0, 1000, 4000, 6000, 9000, 12000, 14000, 18000, 22000, 25000, 30000, 35000, 39000, 44000, 50000, 56000, 64000, 74000, 82000, 92000, 104000, 114000, 126000, 140000, 152000, 166000, 182000, 196000, 212000, 230000, 247000, 264000, 278000, 296000, 314000, 329000, 347000, 366000, 386000, 402000, 421000, 441000, 462000, 479000, 499000, 520000, 542000, 560000, 582000, 605000, 630000, 660000, 695000, 720000, 750000, 785000, 825000, 855000, 892000, 937000, 989000, 1024000, 1071000, 1126000, 1191000, 1231000, 1281000, 1338000, 1403000, 1448000, 1503000, 1568000, 1643000, 1703000, 1778000, 1853000, 1933000, 2023000, 2098000, 2208000, 2328000, 2458000, 2548000, 2683000, 2818000, 2953000, 3053000, 3193000, 3333000, 3473000, 3593000, 3738000, 3883000, 4028000, 4158000, 4308000, 4458000, 4608000, 4743000, 4898000, 5033000, 5168000, 5303000, 5438000, 5538000, 5673000, 5808000, 5943000, 6078000, 6178000, 6313000, 6448000, 6583000, 6718000, 6818000, 6953000, 7088000, 7223000, 7358000, 7458000, 7593000, 7728000, 7863000, 7998000, 8098000, 8233000, 8368000, 8503000, 8638000, 8738000, 8873000, 9008000, 9143000, 9278000, 9378000, 9513000, 9648000, 9783000, 9918000, 10018000, 10153000, 10288000, 10423000, 10558000, 10658000, 10793000, 10928000, 11063000, 11198000, 11298000, 11433000, 11568000, 11703000, 11838000, 11938000, 12073000, 12208000, 12343000, 12478000, 12578000, 12713000, 12848000, 12983000, 13118000, 13218000, 13353000, 13488000, 13623000, 13758000, 13858000, 13993000, 14128000, 14263000, 14398000, 14498000, 14633000, 14768000, 14903000, 15038000, 15138000, 15273000, 15408000, 15543000, 15678000, 15778000, 15913000, 16048000, 16183000, 16318000, 16418000, 16553000, 16688000, 16823000, 16958000, 17058000, 17193000, 17328000, 17463000, 17598000, 17698000, 17833000, 17968000, 18103000, 18238000, 18338000, 18473000, 18608000, 18743000, 18878000, 18978000, 19113000, 19248000, 19383000, 19518000, 19618000, 19753000, 19888000, 20023000, 20158000, 20258000, 20393000, 20528000, 20663000, 20798000, 20898000, 21033000, 21168000, 21303000, 21438000, 21538000, 21673000, 21808000, 21943000, 22078000, 22178000, 22313000, 22448000, 22583000, 22718000, 22818000, 22953000, 23088000, 23223000, 23358000, 23458000, 23593000, 23728000, 23863000, 23998000, 24098000, 24233000, 24368000, 24503000, 24638000, 24738000, 24873000, 25008000, 25143000, 25278000, 25378000, 25513000, 25648000, 25783000, 25918000, 26018000, 26153000, 26288000, 26423000, 26558000, 26658000, 26793000, 26928000, 27063000, 27198000, 27298000, 27433000, 27568000, 27703000, 27838000, 27938000, 28073000, 28208000, 28343000, 28478000, 28578000, 28713000, 28848000, 28983000, 29118000, 29218000, 29353000, 29488000, 29623000, 29758000, 29858000, 29993000, 30128000, 30263000, 30398000, 30498000];
var new_levels = [0, 3000, 16500, 25500, 39000, 52500, 61500, 79500, 97500, 111000, 133500, 156000, 174000, 196500, 223500, 250500, 286500, 331500, 367500, 412500, 466500, 511500, 565500, 628500, 682500, 745500, 817500, 880500, 952500, 1033500, 1110000, 1186500, 1249500, 1330500, 1411500, 1479000, 1560000, 1645500, 1735500, 1807500, 1893000, 1983000, 2077500, 2154000, 2244000, 2338500, 2437500, 2518500, 2617500, 2721000, 2833500, 2968500, 3126000, 3238500, 3373500, 3531000, 3711000, 3846000, 4012500, 4215000, 4449000, 4606500, 4818000, 5065500, 5358000, 5538000, 5763000, 6019500, 6312000, 6514500, 6762000, 7054500, 7392000, 7662000, 7999500, 8337000, 8697000, 9102000, 9439500, 9934500, 10474500, 11059500, 11464500, 12072000, 12679500, 13287000, 13737000, 14367000, 14997000, 15627000, 16167000, 16819500, 17472000, 18124500, 18709500, 19384500, 20059500, 20734500, 21342000, 22039500, 22647000, 23254500, 23862000, 24469500, 24919500, 25527000, 26134500, 26742000, 27349500, 27799500, 28407000, 29014500, 29622000, 30229500, 30679500, 31287000, 31894500, 32502000, 33109500, 33559500, 34167000, 34774500, 35382000, 35989500, 36439500, 37047000, 37654500, 38262000, 38869500, 39319500, 39927000, 40534500, 41142000, 41749500, 42199500, 42807000, 43414500, 44022000, 44629500, 45079500, 45687000, 46294500, 46902000, 47509500, 47959500, 48567000, 49174500, 49782000, 50389500, 50839500, 51447000, 52054500, 52662000, 53269500, 53719500, 54327000, 54934500, 55542000, 56149500, 56599500, 57207000, 57814500, 58422000, 59029500, 59479500, 60087000, 60694500, 61302000, 61909500, 62359500, 62967000, 63574500, 64182000, 64789500, 65239500, 65847000, 66454500, 67062000, 67669500, 68119500, 68727000, 69334500, 69942000, 70549500, 70999500, 71607000, 72214500, 72822000, 73429500, 73879500, 74487000, 75094500, 75702000, 76309500, 76759500, 77367000, 77974500, 78582000, 79189500, 79639500, 80247000, 80854500, 81462000, 82069500, 82519500, 83127000, 83734500, 84342000, 84949500, 85399500, 86007000, 86614500, 87222000, 87829500, 88279500, 88887000, 89494500, 90102000, 90709500, 91159500, 91767000, 92374500, 92982000, 93589500, 94039500, 94647000, 95254500, 95862000, 96469500, 96919500, 97527000, 98134500, 98742000, 99349500, 99799500, 100407000, 101014500, 101622000, 102229500, 102679500, 103287000, 103894500, 104502000, 105109500, 105559500, 106167000, 106774500, 107382000, 107989500, 108439500, 109047000, 109654500, 110262000, 110869500, 111319500, 111927000, 112534500, 113142000, 113749500, 114199500, 114807000, 115414500, 116022000, 116629500, 117079500, 117687000, 118294500, 118902000, 119509500, 119959500, 120567000, 121174500, 121782000, 122389500, 122839500, 123447000, 124054500, 124662000, 125269500, 125719500, 126327000, 126934500, 127542000, 128149500, 128599500, 129207000, 129814500, 130422000, 131029500, 131479500, 132087000, 132694500, 133302000, 133909500, 134359500, 134967000, 135574500, 136182000, 136789500, 137239500];

//Вычисляем сколько очков опыта купил юзер сам
db.users.find().forEach(function(u) { u.points += u.leg_length + u.move_force + u.kick_power; u.points -= get_user_level(u, old_levels); if(u.points < 0) u.points = 0;if(isNaN(u.points)){u.points = 0;};printjson({points: u.points, leg_length: 0, move_force: 0, kick_power: 0 });db.users.update({_id: u._id}, {$set:{points: u.points, leg_length: 0, move_force: 0, kick_power: 0 }})}  );


//Новые границы уровней!
db.user_defaults.update({},{$set:{levels:new_levels, pumping_ticks: 50, level_ranges:[14, 60, 300], pumping_border: [2,2,2,2,2, 2,2,2,2,2, 3,3,3,3,3, 4,4,4,4,4, 5,5,5,5,5, 6,6,6,6,6, 7,7,7,7,7, 8,8,8,8,8, 9,9,9,9,9, 10,10,10,10,10]}})
printjson({levels:new_levels, pumping_ticks: 50, level_ranges:[14, 60, 300], pumping_border: [2,2,2,2,2, 2,2,2,2,2, 3,3,3,3,3, 4,4,4,4,4, 5,5,5,5,5, 6,6,6,6,6, 7,7,7,7,7, 8,8,8,8,8, 9,9,9,9,9, 10,10,10,10,10]});

//Выдаем новые уровни и необходимое кол-во очков
db.users.find().forEach(function(u) { 
	printjson("Old user {_id:" + u._id + ", exp:" + u.experience);
	var old_user_level = get_user_level(u, old_levels);
	var buf_user_level = get_user_level(u, buf_levels);
	var new_user_level = old_user_level;

	var addExps = 0;

	if((buf_user_level - old_user_level) >= 0)
	{
		new_user_level += parseInt((buf_user_level - old_user_level) / 2);
	}

	if(old_levels[old_user_level] != undefined && new_levels[new_user_level] != undefined)
	{
		var progressInOldLevel = parseFloat(u.experience - old_levels[old_user_level - 1]) / (old_levels[old_user_level]  - old_levels[old_user_level - 1]);
		addExps = parseInt(progressInOldLevel * (new_levels[new_user_level] - new_levels[new_user_level - 1]));
	}

	u.experience = new_levels[new_user_level - 1] + addExps; 

	if(isNaN(u.experience))
		u.experience = 0;

	u.last_experience = u.experience; 
	u.points += get_user_level(u, new_levels);
	if(isNaN(u.points)) u.points = 0;
	printjson({experience: u.experience, last_experience: u.last_experience, points: u.points});
	db.users.update({_id: u._id}, {$set:{experience: u.experience, last_experience: u.last_experience, points: u.points}}) 
	}  
);

//Обновить параметры шмоток
//db.weapons.find({"pump_params.move_force":{$exists:true}}).forEach(function(weap){
//	db.weapons.update({_id: weap._id},{$set:{"pump_params.move_force":weap.pump_params.move_force*2}});
//});

//db.weapons.find({"pump_params.kick_power":{$exists:true}}).forEach(function(weap){
//	db.weapons.update({_id: weap._id},{$set:{"pump_params.kick_power":weap.pump_params.kick_power/8}});
//});

//db.weapons.find({"pump_params.leg_length":{$exists:true}}).forEach(function(weap){
//	db.weapons.update({_id: weap._id},{$set:{"pump_params.leg_length":weap.pump_params.leg_length*2}});
//});

var new_3_level_ids = [10, 15, 89];
var new_5_level_ids = [218];
var new_10_level_ids = [7];
var new_14_level_ids = [11,16,90];
var new_15_level_ids = [5];
var new_20_level_ids = [269];
var new_25_level_ids = [272];
var new_30_level_ids = [19];
var new_45_level_ids = [12, 17, 91];
var new_62_level_ids = [13, 18, 92];
var new_63_level_ids = [];
var new_71_level_ids = [221, 222, 223];
var new_83_level_ids = [227, 228, 229];

var little_points_refresh_ids = [259];
var medium_points_refresh_ids = [260];
var big_points_refresh_ids = [261];

if(is_release){
	new_3_level_ids = [28, 33, 107];
	new_5_level_ids = [176];
	new_10_level_ids = [173];
	new_14_level_ids = [29, 34, 108];
	new_15_level_ids = [170];
	new_20_level_ids = [194];
	new_25_level_ids = [246];
	new_30_level_ids = [249];
	new_45_level_ids = [30, 35, 109];
	new_62_level_ids = [31, 36, 110];
	new_63_level_ids = [191, 192, 193];
	new_71_level_ids = [179, 180, 181];
	new_83_level_ids = [185, 186, 187];
	little_points_refresh_ids = [211];
	medium_points_refresh_ids = [212];
	big_points_refresh_ids = [213];
}

function update_item_levels_function (ids_range, new_min_border){
	db.items.update({_id:{$in:ids_range}}, {$set:{level_min:new_min_border}}, {multi: true});
};

function update_item_msx_min_levels_function(ids_range, new_min_border, new_max_border){
	db.items.update({_id: {$in:ids_range}}, {$set:{level_min: new_min_border, level_max: new_max_border}});
}

update_item_levels_function(new_3_level_ids,3);
update_item_levels_function(new_5_level_ids,5);
update_item_levels_function(new_10_level_ids,10);
update_item_levels_function(new_14_level_ids,14);
update_item_levels_function(new_15_level_ids, 15);
update_item_levels_function(new_20_level_ids, 20);
update_item_levels_function(new_25_level_ids, 25);
update_item_levels_function(new_30_level_ids, 30);
update_item_levels_function(new_45_level_ids, 45);
update_item_levels_function(new_62_level_ids, 62);
update_item_levels_function(new_63_level_ids, 63);
update_item_levels_function(new_71_level_ids, 71);
update_item_levels_function(new_83_level_ids, 83);

update_item_msx_min_levels_function(little_points_refresh_ids, 1, 15);
update_item_msx_min_levels_function(medium_points_refresh_ids, 16, 30);
update_item_levels_function(big_points_refresh_ids, 31);


