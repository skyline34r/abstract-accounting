class Deal < ActiveRecord::Base
  validates :tag, :rate, :presence => true
  belongs_to :entity
  belongs_to :give, :polymorphic => true
  belongs_to :take, :polymorphic => true
  has_many :states
  has_many :balances

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
end
