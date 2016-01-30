class TeamGameResult
	include Mongoid::Document

  field :_id, type: Integer
  field :score, type: Integer
  field :leavers, type: Boolean
  field :state, type: Integer, default: 0 # 0 - UNDONE, 1 - WIN, 2 - FAIL, 3 - DRAW
  
  embedded_in :game_result
  embeds_many :user_game_results

  accepts_nested_attributes_for :user_game_results
end
