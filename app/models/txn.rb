class Txn < ActiveRecord::Base
  validates :fact, :presence => true
  validates_uniqueness_of :fact_id
  belongs_to :fact

  before_save :do_before_save

  def from_balance
    @from_balance
  end
  def to_balance
    @to_balance
  end

  private
  def do_before_save
    return false if self.fact.nil?
    self.status = 0
    self.earnings = 0.0
    self.value = 0.0
    @from_balance = nil
    @to_balance = nil
    if !self.fact.from.nil?
      calculate self.fact.from.balance, self.fact.from do |val, balance|
        @from_balance = balance
        if !val.nil?
          self.value = val[0]
        end
        if !@from_balance.amount?
          @from_balance = nil
        end
      end
    end
    if !self.fact.to.isOffBalance
      calculate self.fact.to.balance, self.fact.to do |val, balance|
        @to_balance = balance
        if !val.nil?
          self.earnings = val[0]
          self.status = (val[1] == true ? 1 : 0)
        end
        if !@to_balance.amount?
          @to_balance = nil
        end
      end
    end
    if !self.fact.to.nil? and self.fact.to.income? and self.fact.to.balance.nil?
      self.earnings = -self.value
      self.status = 1
    end
    if self.status == 1
      income = Income.open.first
      income = Income.new if income.nil?
      income.save_or_replace! self.fact.day do |inc|
        inc.txn = self
      end
    end

    self.fact.subfacts.each { |fact| Txn.new(:fact => fact).save! }

    true
  end

  def calculate(aBalance, aDeal)
    return true if (aDeal.nil? or aDeal.income?) and aBalance.nil?
    b = aBalance
    b = Balance.new if b.nil?
    b.save_or_replace!(self.fact.day) do |balance|
      balance.deal = aDeal
      val = balance.txn(self)
      yield(val, balance)
    end
  end
end
