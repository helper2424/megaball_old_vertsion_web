class Sprite
  include Mongoid::Document
  
  auto_increment :_id

  field :x, type: Integer
  field :y, type: Integer

  field :url, type: String
  
  field :z_index, type: Integer

  embedded_in :map
end
