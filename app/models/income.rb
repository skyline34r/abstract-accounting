require "closable"

class Income < ActiveRecord::Base
  validates :start, :side, :value, :presence => true
  validates :start, :uniqueness => true
  validates :side, :inclusion => { :in => %w{passive active} }

  def Income.open
    Income.find_all_by_paid nil
  end

  def quote=(aQuote)
    update_value aQuote.day, aQuote.diff
  end

  def txn=(aTxn)
    return nil if aTxn.status == 0
    update_value aTxn.fact.day, aTxn.earnings
  end

  def amount?
    !self.value.accounting_zero?
  end

  include Closable

  private
  def update_value(aDay, aValue)
    self.side ||= "active"
    if self.start.nil?
      self.start = aDay
      if aValue > 0.0
        self.value = aValue
        self.side = "active"
      else
        self.value = -aValue
        self.side = "passive"
      end
    else
      self.start = aDay
      self.value += self.side == "passive" ? -aValue : aValue
      if self.value.accounting_negative?
        self.value *= -1
        self.side = self.side == "passive" ? "active" : "passive"
      end
    end
  end
end
