class LevelReachPrise < PriseItem
  field :level, type: Integer

  index level: 1

  scope :in_range, ->(a, b) { where :level.gt => a, :level.lte => b }
end
