class Animation
  include Mongoid::Document
  
  auto_increment :_id
  
  field :name, type: String, :default => ''
  field :images, type: Array, :default => []
  field :type, type: String, :default => ''
  
  attr_accessible :name, :images, :type
end
