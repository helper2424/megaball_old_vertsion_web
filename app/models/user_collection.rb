class UserCollectionItem
	include Mongoid::Document
  embedded_in :user
end

class UserCollection
	include Mongoid::Document

  field :collection_id, type: Integer, default: 0
  field :item_id, type: Integer, default: 0
  field :processed, type: Boolean, default: false

  def processed?; self.processed; end
  
  embedded_in :user
end
