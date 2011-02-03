class FactValidator
  def validate(record)
    record.errors[:base] << "bad resource" unless
      record.resource == record.from.take \
        and (record.resource == record.to.give or record.to.income?)
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
    arr = Array.new
    Fact.all.each { |item| arr << item if item.txn.nil?  }
    return arr
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
    return true if (aDeal.nil? or aDeal.income?) and aState.nil?
    (if aState.nil?
      State.new
    else
      aState
    end).save_or_replace!(self.day) do |state|
      state.deal = aDeal
      state.fact = self
    end
    true
  end
end

