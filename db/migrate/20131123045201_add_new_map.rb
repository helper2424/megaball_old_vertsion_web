class AddNewMap < ActiveRecord::Migration
  def create_map base_url, id, ball, field, bann_top, bann_bottom
    map = Map.create _id: id.to_i, width: 1700, height: 800, texture_url: field, markup_url: 'http://' + base_url + '/pictures/field_markup.png', bg_sound_url: 'http://' + base_url + '/sounds/goalloop.wav', type: 1, team_count: 3, team_colors: [0xe7,0xdb526b,0x0069af], banner_top: bann_top, banner_bottom: bann_bottom, friction: 0.95

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
    map.map_balls.create ball_id: ball._id, x: 850, y: 400
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

    map.save!
    map
  end

  def up
    if Rails.env.production?
      base_url = 'dev.r3studio.ru'
    elsif Rails.env.release?
      base_url = 'asset.r3studio.ru'
    else
      base_url = 'localhost:3000'
    end

    ball1 = Ball.find(1)
    vk_news_map = create_map base_url, 5, ball1, 'http://' + base_url + '/pictures/field_ffff.png', 'http://' + base_url + '/pictures/bann_ffff.png', 'http://' + base_url + '/pictures/bann_ffff_2.png'

    GamePlay.gt(_id: 1).delete_all

    first_gp = GamePlay.find 1
    first_gp.map_id = vk_news_map._id
    first_gp.save
  end

  def down
  end
end
