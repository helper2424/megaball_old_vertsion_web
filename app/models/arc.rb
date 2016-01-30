class Arc < Shape
  field :x, type: Integer
  field :y, type: Integer
  field :start_a, type: Float
  field :end_a, type: Float
  field :radius, type: Integer
  field :r1, type: Integer, default: 0
  field :r2, type: Integer, default: 0
  field :inside, type: Boolean, default: true
  field :outside, type: Boolean, default: true
end
