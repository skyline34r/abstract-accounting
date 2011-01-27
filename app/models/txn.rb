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
    calculate(((@from_balance = self.fact.from.balance).nil? ?
      @from_balance = Balance.new : @from_balance), self.fact.from) do |val|
      self.value = val[0]
    end
    calculate((@to_balance = self.fact.to.balance).nil? ?
      @to_balance = Balance.new : @to_balance, self.fact.to) do |val|
      self.earnings = val[0]
      self.status = (val[1] == true ? 1 : 0)
    end
    true
  end

  def calculate(aBalance, aDeal)
    aBalance.save_or_replace!(self.fact.day) do |balance|
      balance.deal = aDeal
      val = balance.txn(self)
      if !val.nil?
        yield(val)
      end
    end
  end
end
