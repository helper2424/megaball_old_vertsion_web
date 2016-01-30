class Champ
  include Mongoid::Document

  auto_increment :_id, :seed  => 1
  field :title, type: String, default: ""
  field :clubs, type: Array, default: []
  
  field :club_level_min, type: Integer, default: 0
  field :club_level_max, type: Integer, default: 0
  
  field :club_rating_min, type: Integer, default: 0
  field :club_rating_max, type: Integer, default: 0
  
  field :player_level_min, type: Integer, default: 0
  field :player_level_max, type: Integer, default: 0
  
  field :entry_price_stars, type: Integer, default: 0
  field :entry_price_coins, type: Integer, default: 0
  
  field :prize1_item_id, type: Integer, default: 0
  field :prize2_item_id, type: Integer, default: 0
  field :prize3_item_id, type: Integer, default: 0
  
  field :cells, type: Array, default: []
  
  field :started, type: Boolean, default: false
  
  field :visible, type: Boolean, default: false
  
  embeds_many :champ_cell
  accepts_nested_attributes_for :champ_cell, allow_destroy: true
end