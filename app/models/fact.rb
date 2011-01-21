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
  has_one :txn

  before_save :do_save

  def self.pendings
    Fact.all.collect { |aFact| aFact if aFact.txn.nil? }
  end

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
      state.fact = self
      return state.save!
    elsif state.start == self.day
      state.fact = self
      if state.amount?
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
      state2.fact = self
      if !state2.amount?
        return state2.save!
      end
    end
    true
  end
end

