class ItemContent
  include Mongoid::Document

  field :content, type: Integer
  field :count, type: Integer
  field :chance, type: Integer, default: 1
  field :is_charge, type: Boolean, default: false
  field :chargable, type: Boolean, default: false

  # Possible values:
  #   hair, eye, mouth, shirt, shorts, shoes, weapon, stars, coins, exclusive
  field :type, type: String

  embedded_in :item  
end
