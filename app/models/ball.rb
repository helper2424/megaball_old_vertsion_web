class Ball
  include Mongoid::Document

  field :_id, type: Integer
  field :radius, type: Integer, :default => 15
  field :texture_url, type: String
  field :weight, type: Integer, :default => 50
  field :bounce, type: Float, :default => 0.95
  field :friction, type: Float, :default => 1.0

  attr_accessible :_id, :radius, :texture_url, :weight, :bounce, :friction
end
