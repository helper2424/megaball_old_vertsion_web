class ChampCell
  include Mongoid::Document

  auto_increment :_id, :seed => 1
  
  field :stage, type: Integer, default: 1
  
  field :club1_id, type: Integer, default: 0
  field :club2_id, type: Integer, default: 0
  field :team1, type: Array, default: []
  field :team2, type: Array, default: []
  
  field :judge, type: Integer, default: 0
  
  field :game_result_id, type: String, default: ""
  
  field :start_time, type: Time
  
  embedded_in :champ
end