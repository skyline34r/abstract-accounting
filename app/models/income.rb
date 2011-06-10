require "closable"

class Income < ActiveRecord::Base
  validates :start, :side, :value, :presence => true
  validates :start, :uniqueness => true
  validates :side, :inclusion => { :in => %w{passive active} }

  def Income.open
    Income.find_all_by_paid nil
  end

  def deal
    Deal.income
  end

  def amount
    0.0
  end

  def self.find_all_between_start_and_stop(start, stop)
    Income.where("start <= ? AND (paid > ? OR paid IS NULL)",
      DateTime.new(stop.year, stop.month, stop.day) + 1,
      DateTime.new(start.year, start.month, start.day) + 1)
  end

  def debit_diff
    Quote.sum(:diff, :conditions => ["day = ? AND diff > 0.0", self.start])
  end

  def credit_diff
    Quote.sum(:diff, :conditions => ["day = ? AND diff < 0.0", self.start]) * -1
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
