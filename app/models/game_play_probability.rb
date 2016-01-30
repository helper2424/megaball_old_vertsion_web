class GamePlayProbability
	include Mongoid::Document

  field :start_level, type: Integer, default: 1
  field :end_level, type: Integer, default: 20
  field :probability, type: Integer, default: 0

  attr_accessible :start_level, :end_level, :probability

  embedded_in :game_play
end
