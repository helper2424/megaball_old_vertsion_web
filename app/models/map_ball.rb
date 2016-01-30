class MapBall
  include Mongoid::Document

  auto_increment :_id
  
  field :x, type: Integer
  field :y, type: Integer

  field :ball_id, type: Integer

  belongs_to :ball
  
  embedded_in :map
end
