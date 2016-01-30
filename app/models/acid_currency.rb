class AcidCurrency < ActiveRecord::Base
  self.table_name = 'currencies'

  belongs_to :acid_gate, foreign_key: "gate_id"

  attr_accessible :currency, :name, :exchange_rate, :date, :gate_id

  default_scope { order("date DESC") }

  def self.current gate
    real = self.joins(:acid_gate).where(gates: {name: gate}, currency: 1).first
    imagine = self.joins(:acid_gate).where(gates: {name: gate}, currency: 2).first

    return {real: real, imagine: imagine}
  end

  def self.calculate_price amount, currency
    return (BigDecimal.new(amount) / currency[:exchange_rate]).ceil
  end

  def self.calculate_amount price, currency
    return (BigDecimal.new(price)*currency[:exchange_rate]).fix
  end
end
