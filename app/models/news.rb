class News
  include Mongoid::Document

  auto_increment :_id, :seed  => 0

  field :show, type: Boolean, default: false
  field :url,  type: Array,  default: []
  field :text, type: Array,  default: []

  index _id: 1, show: 1
end
