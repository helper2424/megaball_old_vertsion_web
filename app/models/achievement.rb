class Achievement
	include Mongoid::Document

  auto_increment :_id, :seed  => 0
  field :title,       localize: true, default: ""
  field :picture,     type: String, default: ""
  field :description, localize: true, default: ""
  field :unique_id,   type: Integer, default: 0

  index :unique_id => 1

  embeds_many :achievement_entry
  accepts_nested_attributes_for :achievement_entry, allow_destroy: true
end
