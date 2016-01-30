# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

if Rails.env.production?
	base_url = 'dev.r3studio.ru'
elsif Rails.env.release?
	base_url = 'mb.r3studio.ru'
else
	base_url = 'localhost:3000'
end

vk_currency_gate = AcidGate.new name: "vk"
vk_currency_gate.save!

robokassa_currency_gate = AcidGate.create! name: "robokassa"

cur_1 = AcidCurrency.new currency: 1, name: 'star', exchange_rate: 6, date: DateTime.now
cur_1.acid_gate = vk_currency_gate
cur_1.save!
cur_2 = AcidCurrency.new currency: 2, name: 'coin', exchange_rate: BigDecimal.new('55'), date: DateTime.now
cur_2.acid_gate = vk_currency_gate
cur_2.save!

cur_1 = AcidCurrency.new currency: 1, name: 'star', exchange_rate:  BigDecimal.new('1'), date: DateTime.now
cur_1.acid_gate = robokassa_currency_gate
cur_1.save!
cur_2 = AcidCurrency.new currency: 2, name: 'coin', exchange_rate: BigDecimal.new('7'), date: DateTime.now
cur_2.acid_gate = robokassa_currency_gate
cur_2.save!

# user stats
UserDefault.create

# Create map with ball in it
ball1 = Ball.create texture_url: 'http://' + base_url + '/pictures/small_ball.png', :radius => 20, :bounce => 0.95, :weight => 75
ball2 = Ball.create texture_url: 'http://' + base_url + '/pictures/big_ball.png', :radius => 30, :weight => 100, :bounce => 0.95
shaiba1 = Ball.create texture_url: 'http://' + base_url + '/pictures/shaiba1.png', :radius => 25, :weight => 80, :friction => 0.8

map = Map.create width: 1700, height: 800, texture_url: 'http://' + base_url + '/pictures/field_grass.png', markup_url: 'http://' + base_url + '/pictures/field_markup.png', bg_sound_url: 'http://' + base_url + '/sounds/goalloop.wav', type: 1, team_count: 3, team_colors: [0xe7,0xdb526b,0x0069af], banner_top: 'http://' + base_url + '/pictures/bann_1.png', banner_bottom: 'http://' + base_url + '/pictures/bann_2.png', friction: 0.95

# horizontal lines
map.lines.create x1:150, y1:50, x2:1550, y2:50, left:false, player_collision:false
map.lines.create x1:150, y1:750, x2:1550, y2:750, right:false, player_collision:false
# vertical lines left
map.lines.create x1:150, y1:50, x2:150, y2:300, right:false, player_collision:false
map.lines.create x1:150, y1:500, x2:150, y2:750, right:false, player_collision:false
# vertical lines right
map.lines.create x1:1550, y1:50, x2:1550, y2:300, left:false, player_collision:false
map.lines.create x1:1550, y1:500, x2:1550, y2:750, left:false, player_collision:false

# left net (ok)
# left net back (ok)
map.lines.create x1:100, y1:290, x2:90, y2:510, player_collision:true, r1:2, r2:2
# left net top (ok)
map.lines.create x1:100, y1:290, x2:150, y2:300, player_collision:true
# left net bottom (ok)
map.lines.create x1:90, y1:510, x2:150, y2:500, player_collision:true
# right net
# right net back (ok)
map.lines.create x1:1610, y1:290, x2:1600, y2:510, player_collision:true, r1:2, r2:2
# right net top (ok)
map.lines.create x1:1610, y1:290, x2:1550, y2:300, player_collision:true
# right net bottom (ok)
map.lines.create x1:1600, y1:510, x2:1550, y2:500, player_collision:true

#gates
map.gates.create x1:150, x2:150, y1:300, y2:500, team:1, r1:10, r2:10
map.gates.create x1:1550, x2:1550, y1:300, y2:500, team:2, r1:10, r2:10

#balls
map.map_balls.create ball_id: ball1._id, x: 850, y: 400
#map.map_balls.create ball_id: ball2._id, x: 850, y: 400
#map.map_balls.create ball_id: ball3._id, x: 800, y: 480

#start positions
map.start_positions.create x: 800, y: 400, team: 1, special: true
map.start_positions.create x: 650, y: 400, team: 1
map.start_positions.create x: 650, y: 300, team: 1
map.start_positions.create x: 650, y: 500, team: 1
map.start_positions.create x: 750, y: 400, team: 1
map.start_positions.create x: 750, y: 300, team: 1
map.start_positions.create x: 750, y: 500, team: 1

map.start_positions.create x: 900, y: 400, team: 2, special: true
map.start_positions.create x: 1050, y: 400, team: 2
map.start_positions.create x: 1050, y: 300, team: 2
map.start_positions.create x: 1050, y: 500, team: 2
map.start_positions.create x: 950, y: 400, team: 2
map.start_positions.create x: 950, y: 300, team: 2
map.start_positions.create x: 950, y: 500, team: 2

# sprites
map.sprites.create x: 115, y: 400, url: 'http://' + base_url + '/pictures/l_gate.png', z_index: 5
map.sprites.create x: 1586, y: 400, url: 'http://' + base_url + '/pictures/r_gate.png', z_index: 5
#map.in_game_position.create x: 50, y: 400, team: 1
#map.in_game_positions.create x: 1550, y: 400, team: 2

#weapons
# 0 - skill, 1 - hat, 2 - shirt, 3 - shoes, 4 - amulet, 5 - bottle, 6 - shorts

Weapon.create _id:1, charge: 50, texture: 'http://' + base_url + '/pictures/push.png', action: 1 #PUSH_PLAYES


# store
bottles_id = 1
skills_id = 2
clothes_id = 3
sets_id = 4
faces_id = 5

#bots
bot_count = 100
bot_count = 10000 if Rails.env.release? 

bot_count.times do |i|
  buf = User.create!({:name => "Bot_"+i.to_s, :email => 'bot_'+i.to_s() + '@some.com',
    :password => "111111", :password_confirmation => "111111", :token => 1,
    :exp_date => 1577858400 })

  UserWeapon.create user_id: buf._id, texture: 'http://' + base_url + '/pictures/push.png', charge: 100, action: 1, active: true #PUSH_PLAYES
  UserWeapon.create user_id: buf._id, texture: 'http://' + base_url + '/pictures/teleport.png', charge: 100, action: 2, active: true #TELEPORT_SELF
end

