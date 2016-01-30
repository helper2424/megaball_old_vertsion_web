class DailyMission < PriseItem
  before_save :randomize

  field :params, type: Hash, default: {}
  field :type, type: Integer, default: 0
  field :random, type: Float 
  
  field :title, localize: true, default: 'No title'
  field :description, localize: true, default: 'No description'

  scope :with_ids, ->(ids){ where(:_id.in => ids) }

  def achieved? user
    nil == self.params.find_index do |key, param|
      diff = user.attr_by_string(key).to_i - user.daily_mission_backup[key].to_i
      diff < param
    end
  end

  private

  def randomize
    self.random = rand
  end
end
