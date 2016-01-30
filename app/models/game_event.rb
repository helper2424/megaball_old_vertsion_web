class GameEvent
  include Mongoid::Document

  # game data
  field :_id, type: Integer
  field :sound, type: String
  field :animation_id, type: Integer, :default => 0
  field :duration, type: Integer, :default => 0

  attr_accessible :_id, :sound, :animation_id, :duration

  belongs_to :animation

  index :animation_id => 1

  def as_json(opts={})
    super({
      include: {
        animation: {}
      }
    })
  end
end
