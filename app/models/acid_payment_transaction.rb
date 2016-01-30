class AcidPaymentTransaction < ActiveRecord::Base
  self.table_name = 'payment_transactions'

  belongs_to :acid_user, foreign_key: "user_id"
  belongs_to :acid_currency, foreign_key: "currency_id"

  attr_accessible :date, :gate_currency_amount, :our_currency_amount, :additional, :bonus
end
