class Gate
  include Mongoid::Document

  field :x1, type: Integer
  field :x2, type: Integer
  field :y1, type: Integer
  field :y2, type: Integer
  field :r1, type: Integer, :default => 0
  field :r2, type: Integer, :default => 0
  field :team, type: Integer
  
  embedded_in :map

  def as_json(options={})
    super :only => [:x1, :x2, :y1, :y2, :team]
  end
end
