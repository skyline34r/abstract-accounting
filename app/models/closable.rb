module Closable
  def save_or_replace!(aDay)
    if self.new_record?
      yield(self)
      return self.save!
    elsif self.start == aDay
      yield(self)
      if !self.amount?
        return self.destroy
      else
        return self.save!
      end
    else
      state2 = self.clone
      self.paid = aDay
      self.save!
      yield(state2)
      if state2.amount?
        return state2.save!
      end
    end
  end
end
