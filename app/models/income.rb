class Income < ActiveRecord::Base
  validates :start, :side, :value, :presence => true
  validates :start, :uniqueness => true
  validates :side, :inclusion => { :in => %w{passive active} }

  def Income.open
    Income.find_all_by_paid nil
  end

  def txn=(aTxn)
    return nil if aTxn.status == 0
    self.side ||= "active"
    if self.new_record?
      self.start = aTxn.fact.day
      if aTxn.earnings > 0.0
        self.value = aTxn.earnings
        self.side = "active"
      else
        self.value = -aTxn.earnings
        self.side = "passive"
      end
    else
      self.value += self.side == "passive" ? -aTxn.earnings : aTxn.earnings
      if self.value.accounting_negative?
        self.value *= -1
        self.side = self.side == "passive" ? "active" : "passive"
      end
    end
  end
end
