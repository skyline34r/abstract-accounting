class State < ActiveRecord::Base
  validates :amount, :start, :side, :deal, :presence => true
  validates_inclusion_of :side, :in => ["passive", "active"] #[1, 0]
  belongs_to :deal
  
  after_initialize :do_init
  
  def resource
    return nil? unless self.deal
    return self.deal.take if self.side == "passive"
    self.deal.give
  end
  
  def apply_fact(aFact)
    return false if self.deal.nil?
    return false if aFact.nil?
    true if set_fact_side(aFact) and update_time(aFact.day)
  end

  def is_zero?
    is_zero(self.amount)
  end
  
  private
  def do_init
    self.side ||= "active"
    self.amount ||= 0.0
  end
  
  def set_fact_side(aFact)
    return false if aFact.nil?
    fact_side =
      if self.deal == aFact.from
        "passive"
      else
        "active"
      end
    
    rate = self.deal.rate
    if self.side == fact_side
      self.amount -= aFact.amount
    else
      self.amount += aFact.amount *
        if self.side == "passive"
          rate
        else
          1/rate
        end
    end
    
    if !is_zero(self.amount) and self.amount < 0.0
      self.side =
        if self.side == "passive"
          "active"
        else
          "passive"
        end
      self.amount *= -1 *
        if self.side == "passive"
          rate
        else
          1/rate
        end
    end
    self.amount = norm_value(self.amount)
    true
  end
  
  def update_time(aTime)
    self.start = aTime
    true
  end

  #helpers
  def is_zero(value)
    value < 0.00009 and value > -0.00009
  end
  def round64(value)
    return (value - 0.5).ceil if value < 0.0
    (value + 0.5).floor
  end
  def norm_value(value)
    round64(value * 100.0) / 100.0
  end
end
