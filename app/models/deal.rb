class Deal < ActiveRecord::Base
  validates :tag, :rate, :presence => true
  belongs_to :entity
  belongs_to :give, :polymorphic => true
  belongs_to :take, :polymorphic => true
  has_many :states
  has_many :balances
  has_many :rules

  def Deal.income
    #TODO: deprecate any changes
    income = Deal.where(:id => 0).first
    income = Deal.new :tag => "profit and loss", :rate => 1.0 if income.nil?
    income.id = 0 if income.id.nil?
    income
  end
  def income?
    self.id == 0
  end
  def state(day = nil)
    states.where(:start =>
        if !day.nil?
          states.where("start <= ?", day)
            .maximum("start")
        else
          states.maximum("start")
        end
      ).where("paid is NULL").first
  end
  def balance(day = nil, paid = nil)
    ret_balances = (if day.nil?
                      balances
                    else
                      balances.where("start <= ?", day)
                    end).where(
                    (if paid.nil?
                      "paid is ?"
                    else
                      "paid <= ?"
                    end), paid)
    return nil if ret_balances.empty?
    ret_balances.first
  end
  def balance_range(start, stop)
    balances.where("start <= ? AND paid > ?",
      DateTime.new(start.year, start.month, start.day) + 1,
      DateTime.new(stop.year, stop.month, stop.day))
  end

  def txns(start, stop)
    Txn.find_all_by_fact_id \
      Fact.find_all_by_deal_id(self.id).where("day > ? AND day < ?",
        DateTime.new(start.year, start.month, start.day),
        DateTime.new(stop.year, stop.month, stop.day) + 1).
          collect { |item| item.id }
  end
end
