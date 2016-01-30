class GamePlay
	include Mongoid::Document

  field :_id, type: Integer
  field :name, localize: true, default: ''
  field :map_id, type: Integer
  field :max_players, type: Integer
  field :time_size, type: Integer
  field :time_qty, type: Integer
  field :events, type: Array
  field :mode, type: Integer, default: 0
  
  field :texture, type: String
  
  field :allowed_type, type: Array, default: [1,2,3,4]
  
  index max_players: 1

  belongs_to :map

  embeds_many :game_play_probabilities
  accepts_nested_attributes_for :game_play_probabilities, allow_destroy: true
  
  attr_accessible :_id, :name, :map_id, :max_players, :time_size, :time_qty, :map, :allowed_type, :texture, :mode, :game_play_probabilities
  attr_accessible :events
  attr_accessible :game_play_probabilities_attributes

  def events
    GameEvent.where(:id.in => self[:events])
  end
end
