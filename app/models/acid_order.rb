class AcidOrder	 < ActiveRecord::Base
  self.table_name = 'orders'

  belongs_to :acid_user, foreign_key: "user_id"

  attr_accessible :date, :balance_type, :amount, :product_id, :qti, :balance

  default_scope { order("date DESC") }
end
