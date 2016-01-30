class AcidClub < ActiveRecord::Base

  self.table_name = 'clubs'

  attr_accessible :real_balance, :id, :imagine_balance
  after_save :cache_currencies
  after_update :cache_currencies

  validates_numericality_of :real_balance, greater_than_or_equal_to: 0
  validates_numericality_of :imagine_balance, greater_than_or_equal_to: 0

  def cache_currencies 
    mongo_club = Club.find self.id

    if !mongo_club.nil?
      mongo_club.set(:coins, self.imagine_balance)
      mongo_club.set(:stars, self.real_balance)
      true
    else
      false
    end
  end

  def payment(currency_type, amount, bonus = 0)
    case currency_type
    when :real then self.real_balance += amount + bonus
    when :imagine then self.imagine_balance += amount + bonus
    else return false
    end
    self.save!
  end

  def buy(currency_type, amount)
    case currency_type
    when :real then self.real_balance -= amount
    when :imagine then self.imagine_balance -= amount
    else return false
    end
    self.save!
  end

  def can_pay_for?(currency_type, amount)
    amount >= 0 &&
      ((currency_type == :real) ?
        self.real_balance >= amount :
        (currency_type == :imagine) ?
          self.imagine_balance >= amount :
          false)
  end

  def balance_for(currency_type)
    case currency_type
    when :real then self.real_balance
    when :imagine then self.imagine_balance
    else return false
    end
  end
end
