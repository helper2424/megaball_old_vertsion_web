class Line < Shape
  
  field :x1, type: Integer
  field :x2, type: Integer
  field :y1, type: Integer
  field :y2, type: Integer
  field :r1, type: Integer, default: 0
  field :r2, type: Integer, default: 0
  field :left, type: Boolean, default: true
  field :right, type: Boolean, default: true
  
  embedded_in :map
end
