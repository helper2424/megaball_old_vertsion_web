class Shape
  include Mongoid::Document

  field :visible, type: Boolean, default: true
  field :state, type: Array, default: [:all]
  field :texture_url, type: String
  field :player_collision, type: Boolean, default: true
  field :shape_collision, type: Boolean, default: true

  embedded_in :map
end
