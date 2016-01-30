class PriseItem
  include Mongoid::Document

  auto_increment :_id, seed: 0

  field :items, type: Array, default: []
  field :stars, type: Integer, default: 0
  field :coins, type: Integer, default: 0
 
end
