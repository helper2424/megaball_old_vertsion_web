class UserGameResult
  include Mongoid::Document

  field :_id, type: Integer, default: 0
  field :group_id, type: Integer, default: 0
  field :distance_walked, type: Float, default: 0.0
  field :ball_kicks, type: Integer, default: 0
  field :player_kicks, type: Integer, default: 0
  field :nitro_used, type: Float, default: 0.0
  field :goals, type: Integer, default: 0
  field :goal_passes, type: Integer, default: 0
  field :gate_saves, type: Integer, default: 0
  field :rod_hits, type: Integer, default: 0
  field :best, type: Boolean, default: false
  field :experience, type: Integer, default: 0
  field :rating, type: Integer, default: 0
  field :stars, type: Integer, default: 0
  field :coins, type: Integer, default: 0
  field :exp_for_max_goal_passes, type: Integer, default: 0
  field :exp_for_max_gate_saves, type: Integer, default: 0
  field :exp_for_max_goals, type: Integer, default: 0
  field :exp_for_max_gate_saves, type: Integer, default: 0
  field :team_mates, type: Integer, default: 0
  field :leaver, type: Boolean, default: false
  embedded_in :team_game_result
end
