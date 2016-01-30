class DailyMissionRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  field :entries, type: Array

  scope :today, ->{ where(:created_at.gte => Time.now.beginning_of_day) }
end
