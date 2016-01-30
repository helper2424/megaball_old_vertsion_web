class AcidUser < ActiveRecord::Base

  self.table_name = 'users'

  attr_accessible :real_balance, :id, :imagine_balance
  after_save :cache_currencies
  after_update :cache_currencies

  validates_numericality_of :real_balance, greater_than_or_equal_to: 0
  validates_numericality_of :imagine_balance, greater_than_or_equal_to: 0

  # User it for achievments, game results ...
  def contribute_currency amount, currency, comment=''
    AcidUser.transaction do
      self.lock!

      currencies = AcidCurrency.current 'self'

      transaction = AcidPaymentTransaction.new date: DateTime.now, gate_currency_amount: amount, our_currency_amount: amount, bonus: 0, additional: comment 
      transaction.acid_user = self
      transaction.acid_currency = currencies[currency]
      transaction.save!

      if currency == :real
        self.real_balance += amount
      else
        self.imagine_balance += amount
      end

      self.save
    end
  end

  def cache_currencies 
    mongo_user = User.find self.id

    if !mongo_user.nil?
      mongo_user.update_attributes! coins: self.imagine_balance, stars: self.real_balance
      true
    end

    false
  end

  def payment currency_type, amount, bonus = 0
    case currency_type
    when :real
      self.real_balance += amount + bonus
    when :imagine 
      self.imagine_balance += amount + bonus
    else
      return false
    end

    self.save!

    return true
  end

  def buy currency_type, amount
    case currency_type
    when :real
      self.real_balance -= amount 
    when :imagine 
      self.imagine_balance -= amount 
    else
      return false
    end

    self.save!

    return true
  end

  def can_pay_for?(currency_type, amount)
    amount >= 0 &&
      ((currency_type == :real) ?
        self.real_balance >= amount :
        (currency_type == :imagine) ?
          self.imagine_balance >= amount :
          false)
  end
end
