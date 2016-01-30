class InGamePosition
  include Mongoid::Document

  field :x, type: Integer
  field :y, type: Integer

  field :team, type: Integer

  embedded_in :map
end
