class PendingMoney
  include Mongoid::Document

  field :type, type: String, :default => 'nothing' # coins, stars
  field :msg, type: String, :default => 'no_info'
  field :amount, type: Integer, :default => 0

  embedded_in :user
end