
module StateAction
  
  def resource
    return nil if self.deal.nil?
    return self.deal.take if self.side == "passive"
    self.deal.give
  end

  def fact=(aFact)
    return false if self.deal.nil?
    return false if aFact.nil?
    self.start = aFact.day if init_from_fact(aFact)
    self.start_changed?
  end

  def amount?
    self.amount.accounting_zero?
  end

  protected
  def do_init
    self.side ||= "active" if self.attributes.has_key?('side')
    self.amount ||= 0.0 if self.attributes.has_key?('amount')
  end

  def init_from_fact(aFact)
    return false if aFact.nil?
    @fact_side =
      if self.deal == aFact.from
        "passive"
      else
        "active"
      end

    if self.methods.include?('value_i')
      @old_amount = self.amount
      @old_value = self.value_i()
    end

    if self.side == @fact_side
      self.amount -= aFact.amount
    else
      self.amount += aFact.amount * self.rate
    end

    if self.amount.accounting_negative?
      self.side =
        if self.side == "passive"
          "active"
        else
          "passive"
        end
      self.amount *= -1 * self.rate
      if self.methods.include?('value')
        @old_value = -@old_value
      end
    end
    self.amount = self.amount.accounting_norm
    true
  end

  def rate
    return 0.0 if self.deal.nil?
    if self.side == "passive"
      self.deal.rate
    else
      1.0 / self.deal.rate
    end
  end
end
