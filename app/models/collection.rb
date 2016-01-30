class Collection
	include Mongoid::Document

  auto_increment :_id, :seed  => 0
  field :title, type: String, default: ""

  # prise
  field :coins, type: Integer, default: 0
  field :stars, type: Integer, default: 0
  field :items, type: Array, default: []

  embeds_many :collection_item
  accepts_nested_attributes_for :collection_item, allow_destroy: true

  def completed_by? user
    whole = self.collection_item.index do |x| 
      item = user.user_collection.index do |y| 
        y.collection_id == self._id and y.item_id == x._id
      end
      item.nil?
    end
    whole.nil?
  end
  
  def join_user user
    user_collections = user.user_collection
    collection_item.map do |item|
      i = user_collections.index do |x| 
        x.collection_id == _id and x.item_id == item._id
      end
      item[:active] = not(i.nil?)
      item
    end
    self
  end
end
