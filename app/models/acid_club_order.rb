class AcidClubOrder < ActiveRecord::Base
  self.table_name = 'club_orders'

  belongs_to :acid_club, foreign_key: "club_id"

  attr_accessible :date, 
                  :amount, 
                  :balance_type, 
                  :product_id, 
                  :product_type, 
                  :qti, 
                  :balance

  default_scope { order("date DESC") }

  def self.product_type_for(val)
    case val
    when :system then 0
    when :store  then 1
    else val
    end
  end

  def self.balance_type_for(val)
    case val
    when :real then 1
    when :imagine then 2
    else val
    end
  end

  def self.new_system_order(currency)
    AcidClubOrder.new(
      date: DateTime.now,
      balance_type: self.balance_type_for(currency),
      product_type: self.product_type_for(:system),
      qti: 1)
  end
end
