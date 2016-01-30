class Map
  include Mongoid::Document

  field :_id, type: Integer
  field :width, type: Integer, default: 100
  field :height, type: Integer, default: 100
  field :type, type: Integer, default: 1
  field :texture_url, type: String
  field :markup_url, type: String
  field :bg_sound_url, type: String
  field :team_count, type: Integer, default: 3
  field :team_colors, type: Array;
  field :friction, type: Float, default: 1.0
  field :banner_top, type: String, default: ""
  field :banner_bottom, type: String, default: ""
  field :banner_left, type: String, default: ""
  field :banner_right, type: String, default: ""
  field :minimap, type: String, default: ""
  
  embeds_many :sprites
  embeds_many :map_balls
  embeds_many :gates
  embeds_many :circles
  embeds_many :lines
  embeds_many :arcs
  embeds_many :start_positions
  embeds_many :in_game_positions

  has_one :game_play

  accepts_nested_attributes_for :sprites
  accepts_nested_attributes_for :map_balls
  accepts_nested_attributes_for :gates
  accepts_nested_attributes_for :circles
  accepts_nested_attributes_for :lines
  accepts_nested_attributes_for :arcs
  accepts_nested_attributes_for :start_positions
  accepts_nested_attributes_for :in_game_positions

  attr_accessible :_id, :width, :height, :type, :texture_url, :markup_url, :bg_sound_url, :team_count, :team_colors, :friction, :banner_top, :banner_bottom, :sprites, :map_balls, :gates, :circles, :lines, :arcs, :start_positions, :in_game_positions, :banner_left, :banner_right, :minimap
  attr_accessible :sprites_attributes
  attr_accessible :map_balls_attributes
  attr_accessible :gates_attributes
  attr_accessible :circles_attributes
  attr_accessible :lines_attributes
  attr_accessible :arcs_attributes
  attr_accessible :start_positions_attributes
  attr_accessible :in_game_positions_attributes
end
