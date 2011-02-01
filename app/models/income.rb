class Income < ActiveRecord::Base
  validates :start, :side, :value, :presence => true
  validates :start, :uniqueness => true
  validates :side, :inclusion => { :in => %w{passive active} }

  def txn=(aTxn)
    return nil if aTxn.status == 0
    if self.new_record?
      self.start = aTxn.fact.day
      if aTxn.earnings > 0.0
        self.value = aTxn.earnings
        self.side = "active"
      else
        self.value = -aTxn.earnings
        self.side = "passive"
      end
    end
  end
end
