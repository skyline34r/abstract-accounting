module Closable
  def save_or_replace!(day)
    if self.new_record?
      yield(self)
      self.save!
    elsif self.start == day
      yield(self)
      if !self.amount?
        return self.destroy
      else
        return self.save!
      end
    elsif self.start < day
      state2 = self.clone
      self.paid = day
      self.save!
      yield(state2)
      if state2.amount?
        return state2.save!
      end
    else
      self.errors[:paid] << ["paid is less then start"]
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end
end
