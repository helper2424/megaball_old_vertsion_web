class Message
	include Mongoid::Document

  auto_increment :_id, :seed  => 0
  field :user_id, type: Integer, default: 0
  field :message, type: String, default: ""
  field :type,    type: String, default: "announcement" # announcement, changelog, levelup, achievement, collection, warning, error, energy_help
  field :date,    type: Time, default: ->{ Time.now }
  
  index user_id: 1
  index date: 1

end
