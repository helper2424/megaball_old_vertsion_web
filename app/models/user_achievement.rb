class UserAchievement
	include Mongoid::Document

  auto_increment :_id, :seed  => 0
  field :achievement, type: Integer
  field :status,      type: Integer, default: 0 # percentage
  field :stage,       type: Integer, default: 0 # achievement entry
  field :achieved,    type: Boolean, default: false

  embedded_in :user
end
