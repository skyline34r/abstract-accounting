class FactValidator
  def validate(record)
    record.errors[:base] << "bad resource" unless
      record.resource == record.from.take \
        and record.resource == record.to.give
  end
end

class Fact < ActiveRecord::Base
  validates :day, :amount, :resource, :from, :to, :presence => true
  validates_with FactValidator
  belongs_to :resource, :polymorphic => true
  belongs_to :from, :class_name => "Deal", :foreign_key => "from_deal_id"
  belongs_to :to, :class_name => "Deal", :foreign_key => "to_deal_id"

  before_save :do_save

  private
  def do_save
    if changed? or new_record?
      return false unless init_state(self.from.state(nil), self.from)
      return false unless init_state(self.to.state(nil), self.to)
    end
  end
  
  def init_state(aState, aDeal)
    return false if aDeal.nil?
    state =
      if aState.nil?
        State.new
      else
        aState
      end
    if state.new_record?
      state.deal = aDeal
      state.apply_fact(self)
      return state.save!
    elsif state.start == self.day
      state.apply_fact(self)
      if state.is_zero?
        return state.destroy
      else
        return state.save!
      end
    else
      state.paid = self.day
      state.save!
      state2 = State.new \
        :start => self.day,
        :amount => state.amount,
        :deal => aDeal,
        :side => state.side
      state2.apply_fact(self)
      return state2.save!
    end
#    state.deal = aDeal
#    state.apply_fact(self)
#    if state.new_record? or state.start == self.day
#      state.save!
#    elsif state.
#    end
  end
end

