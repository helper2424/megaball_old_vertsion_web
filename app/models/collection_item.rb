class CollectionItem
	include Mongoid::Document

  auto_increment :_id, :seed => 0
  field :texture_id, type: Integer, default: 0

  embedded_in :collection
end
