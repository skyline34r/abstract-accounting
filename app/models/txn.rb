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
    @from_balance = self.fact.from.balance
    @to_balance = self.fact.to.balance
    calculate
    @from_balance.save!
    @to_balance.save!
    true
  end

  def calculate
    self.status = 0
    self.earnings = 0.0
    self.value = 0.0
    val = @from_balance.txn(self)
    if !val.nil?
      self.value = val[0]
    end
    val = @to_balance.txn(self)
    if !val.nil?
      self.earnings = val[0]
      self.status = (val[1] == true ? 1 : 0)
    end
  end
end
