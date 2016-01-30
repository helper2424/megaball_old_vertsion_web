# -*- encoding : utf-8 -*-

class UserDefault
  include Mongoid::Document

  field :player_bounce, :type => Float, :default => 0.8
  
  field :leg_length_min, :type => Integer, :default => 5
  field :leg_length_max, :type => Integer, :default => 20
  field :kick_power_min, :type => Integer, :default => 700
  field :kick_power_max, :type => Integer, :default => 1000
  field :move_force_min, :type => Integer, :default => 900
  field :move_force_max, :type => Integer, :default => 1200
  field :super_kick_power_min, :type => Float, :default => 1.8
  field :super_kick_power_max, :type => Float, :default => 2.5
  field :super_kick_power_steps, :type => Integer, :default => 10
  field :super_kick_restore_factor, type: Integer, default: 10
  field :mana_top_max, type: Integer, default: 300
  field :mana_top_min, type: Integer, default: 50
  field :mana_repair_factor, type: Float, default: 0.1
  
  field :games_for_star, :type => Integer, :default => 10
  field :stars_for_first_games, :type => Integer, :default => 1
  
  field :pumping_ticks, :type => Integer, :default => 20
  #границы очков прокачки для получения следующего уровня умения, индекс - текущее значение хар-ки, значение - сколько надо очков прокачки
  field :pumping_border, :type => Array, :default => [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]

  field :pumping_perk_borders, :type => Hash, :default =>
  {
    :perk_nitro_repair_latency => {param: :nitro_speed, borders: [5, 20, 35]}, 
    :perk_nitro_repair_speed => {param: :nitro_speed, borders: [10, 25, 40]}, 
    :perk_nitro_dribbling_user => {param: :nitro_speed, borders: [15, 30, 45]}, 
    :perk_super_kick_repair_enemy_kick_ball => {param: :kick_power, borders: [5, 20, 35]}, 
    :perk_super_kick_repair_enemy_kick_player => {param: :kick_power, borders: [10, 25, 40]}, 
    :perk_super_kick_slowdown_enemy => {param: :kick_power, borders: [15, 30, 45]}, 
    :perk_mana_repair_speed => {param: :mana_top, borders: [5, 20, 35]}, 
    :perk_mana_chance_to_return => {param: :mana_top, borders: [10, 25, 40]}, 
    :perk_mana_start_with_mana => {param: :mana_top, borders: [15, 30, 45]}
  }
  
  field :radius, :type => Integer, :default => 30
  field :acceleration, :type => Float, :default => 10
  field :weight, :type => Integer, :default => 100
  field :friction_on_move, :type => Float, :default => 4.0
  field :friction_on_kick, :type => Float, :default => 8.0
  field :nitro_force_min, :type => Integer, :default => 450
  field :nitro_force_max, :type => Integer, :default => 550
  field :nitro_max, :type => Float, :default => 15.0
  field :nitro_spend_speed, :type => Float, :default => 3.0
  field :nitro_restore_speed, :type => Float, :default => 0.5
  field :nitro_repair_latency, type: Float, default: 2
  field :nitro_repair_zero_latency, type: Float, default: 0.5
  
  field :push_players_radius, :type => Integer, :default => 100
  field :push_players_radius_max, :type => Integer, :default => 150
  field :push_players_speed, :type => Integer, :default => 450
  
  field :pull_balls_radius, :type => Integer, :default => 150
  field :pull_balls_radius_max, :type => Integer, :default => 250
  field :pull_balls_speed, :type => Integer, :default => 300
  
  field :rush_self_speed, :type => Integer, :default => 800

  field :stun_on_touch_time, :type => Integer, :default => 10000

  field :teleport_self_radius, :type => Integer, :default => 175
  
  field :slowdown_players_radius, :type => Integer, :default => 85
  field :slowdown_players_speed, :type => Float, :default => 0.9

  field :reverse_players_radius, :type => Integer, :default => 85
  
  field :levels, :type => Array, :default => [0, 3, 50, 200, 400, 700, 1200, 2000, 3000, 4200, 5500, 7000, 9000, 11000, 13000, 15000, 17000, 19000, 22000, 25000 ]
                                              
  field :exp_for_win, :type => Integer, :default => 10
  field :exp_for_draw, :type => Integer, :default => 5
  field :exp_for_fail, :type => Integer, :default => 3
  field :coins_for_win, :type => Integer, :default => 12
  field :coins_for_draw, :type => Integer, :default => 9
  field :coins_for_fail, :type => Integer, :default => 6
  field :rating_for_win, :type => Integer, :default => 10
  field :rating_for_draw, :type => Integer, :default => 5
  field :rating_for_fail, :type => Integer, :default => 3
  field :rating_for_win_arena, :type => Integer, :default => 5
  field :rating_for_draw_arena, :type => Integer, :default => 3
  field :rating_for_fail_arena, :type => Integer, :default => 1
  
  
  field :goals_delta, :type => Integer, :default => 3
  field :exp_for_goals_delta, :type => Integer, :default => 2
  field :exp_for_max_goals, :type => Integer, :default => 2
  field :exp_for_max_gate_saves, :type => Integer, :default => 2
  field :exp_for_max_goal_passes, :type => Integer, :default => 2
  field :energy_for_play, :type => Integer, :default => 15
  field :energy_for_play_arena, :type => Integer, :default => 10
  field :energy_per_friend, type: Integer, default: 5
  field :energy_max_restore, type: Integer, default: 100
  field :default_energy_item_id, type: Integer, default: 85

  field :enable_level_ranging, :type => Boolean, :default => true
  field :level_ranges, :type => Array, :default => [5,9,20]

  field :collection_item_probability, type: Integer, :default => 10

  field :max_club_requests, :type => Integer, :default => 5
  
  field :stop_game, :type => Boolean, :default => false
  
  field :bet_stars, :type => Array, :default => [0,2,4,8,10]
  field :bet_stars_tax, :type => Array, :default => [0,1,2,4,5]
  field :bet_coins, :type => Array, :default => [0,10,30,50,100]
  field :bet_coins_tax, :type => Array, :default => [0,5,15,25,50]
  field :arena_level_from, :type => Integer, :default => 3

  field :mana_on_field_item_id, :type => Integer, :default => 276
  field :mana_daily, :type => Integer, :default => 10

  field :hair_only, :type => Array, :default => [41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56]
  field :hair_top, :type => Array, :default => [14,21]
  field :scarf, :type => Array, :default => [39,40,41,42,43,44]

  field :vips, :type => Array, :default => [98, 99, 100]
  field :default_vip_item_id, type: Integer, default: 99

  field :chest_exclusive, type: Boolean, default: false 

  # For notifications; The basic check is separately for each user
  field :average_energy_restore_factor, type: Float, :default => 0.5

  # Параметр используется на гейм сервере при инвайте игроков в сердеину матча
  # Если счет будет больш еэтого числа, то игроки не будут закидываться в игру
  field :quick_match_not_invite_with_score_diff, type: Integer, default: 2
  field :quick_match_bonus_for_minimal_team, type: Float, default: 1.5
end
