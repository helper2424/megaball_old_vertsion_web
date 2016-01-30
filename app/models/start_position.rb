class StartPosition
  include Mongoid::Document

  field :x, type: Integer
  field :y, type: Integer

  field :team, type: Integer
  field :special, type: Boolean, :default => false

  embedded_in :map
end
