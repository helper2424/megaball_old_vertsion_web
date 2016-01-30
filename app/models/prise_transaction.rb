class PriseTransaction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id, type: Integer

  field :reason, type: String
  field :content, type: Integer, default: 0
  field :description, type: String, default: ''

  field :items, type: Array, default: []
  field :stars, type: Integer, default: 0
  field :coins, type: Integer, default: 0

  index created_at: 1, item_id: 1
  index created_at: 1, user_id: 1
  index reason: 1, user_id: 1, content: 1

  scope :today, ->{ where :created_at.gt => Time.now.beginning_of_day }
  scope :with_item, ->(item){ where item_id: item }
  scope :with_user, ->(user){ where user_id: user.id }
  scope :with_reason, ->(reason){ where reason: reason }
  scope :with_contents, ->(contents){ where :content.in => contents }
end
