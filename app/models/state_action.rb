
module StateAction
  
  def resource
    return nil if self.deal.nil?
    return self.deal.take if self.side == "passive"
    self.deal.give
  end

  def fact=(aFact)
    return false if self.deal.nil?
    return false if aFact.nil?
    self.start = aFact.day if init_from_fact(aFact) and apply_rules(aFact)
    self.start_changed?
  end

  def amount?
    !self.amount.accounting_zero?
  end

  protected
  def do_init
    self.side ||= "active" if self.attributes.has_key?('side')
    self.amount ||= 0.0 if self.attributes.has_key?('amount')
  end

  def init_from_fact(aFact)
    return false if aFact.nil?
    @diff0 = 0.0
    @diff1 = 0.0
    @fact_side =
      if self.deal == aFact.from
        "passive"
      else
        "active"
      end

    @old_amount = self.amount
    if self.methods.include?(:value_i)
      @old_value = self.value_i()
    end

    if self.side == @fact_side
      @diff0 = aFact.amount
      self.amount -= @diff0
    else
      @diff1 = aFact.amount * self.rate
      self.amount += @diff1
    end

    if self.amount.accounting_negative?
      self.side =
        if self.side == "passive"
          "active"
        else
          "passive"
        end
      self.amount *= -1 * self.rate
      @diff0 = @old_amount
      @diff1 = self.amount
      if self.methods.include?(:value_i)
        @old_value = -@old_value
      end
    end
    self.amount = self.amount.accounting_norm
    @diff0 = @diff0.accounting_norm
    @diff1 = @diff1.accounting_norm
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

  def apply_rules(aFact)
    return false if aFact.nil? or aFact.amount < 0.0
    return false if self.deal.nil?
    self.deal.rules.each do |rule|
      if rule.fact_side ? @fact_side == "passive" : @fact_side == "active"
        amount = 0.0
        amount = @diff0 if !@diff0.accounting_zero? and !rule.change_side
        amount = @diff1 if !@diff1.accounting_zero? and rule.change_side
        if !amount.accounting_zero?
          aFact.use_rule(rule, amount)
        end
      end
    end
    true
  end
end
