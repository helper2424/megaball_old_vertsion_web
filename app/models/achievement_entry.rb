class AchievementEntry
	include Mongoid::Document

  field :params,  type: Hash, default: {}

  # dirty hack
  field :items, type: Array, default: []
  field :stars, type: Integer, default: 0
  field :coins, type: Integer, default: 0

  def achieved? user
    self.params
        .map { |key, val| user.attr_by_string(key, 0) >= val }
        .inject(true, &:&)
  end

  def status_for user
    self.params
        .map { |key, val| (100 * user.attr_by_string(key, 0) / val).round }
        .sum / self.params.count
  end

  embedded_in :achievement
end
