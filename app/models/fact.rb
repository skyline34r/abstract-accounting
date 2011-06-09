class FactValidator
  def validate(record)
    record.errors[:base] << "bad resource" unless
      ((record.from.nil? and !record.to.nil?) or
          (!record.from.nil? and record.resource == record.from.take) or
          (!record.from.nil? and record.from.income?)) \
        and (record.resource == record.to.give or record.to.income?)
  end
end

class Fact < ActiveRecord::Base
  validates :day, :amount, :resource, :to, :presence => true
  validates_with FactValidator
  belongs_to :resource, :polymorphic => true
  belongs_to :from, :class_name => "Deal", :foreign_key => "from_deal_id"
  belongs_to :to, :class_name => "Deal", :foreign_key => "to_deal_id"
  has_one :txn

  before_save :do_save
  after_save :do_after_save
  before_destroy :do_destroy

  def self.pendings
    arr = Array.new
    Fact.all.each { |item| arr << item if item.txn.nil?  }
    return arr
  end

  def subfacts
    @subfacts ||= Array.new
    return @subfacts
  end

  def use_rule(aRule, aAmount)
    return false if aRule.nil? or aAmount.nil? or aAmount.accounting_zero?
    @subfacts ||= Array.new
    @subfacts << Fact.new(:day => self.day, :amount => aRule.rate * aAmount,
            :resource => aRule.from.take, :to => aRule.to, :from => aRule.from)
  end

  def self.find_all_by_deal_id(id)
    Fact.where("from_deal_id == :id or to_deal_id == :id", :id => id)
  end

  private
  def do_save
    if changed? or new_record?
      return false unless init_state(self.from.nil? ? nil : self.from.state(nil), self.from)
      return false unless init_state(self.to.state(nil), self.to)
      subfacts.each { |item| item.save! }
    end
  end
  def do_after_save
    if !User.current.nil?
      return false unless Journal.new(:created_at => DateTime.now,
        :created_by => User.current, :fact => self).save!
    end
  end

  def do_destroy
    self.amount = -self.amount
    init_state self.from.state(nil), self.from
    init_state self.to.state(nil), self.to
  end
  
  def init_state(state, deal)
    return true if (deal.nil? or deal.income?) and state.nil?
    (if state.nil?
      State.new
     else
      state
    end).save_or_replace!(self.day) do |new_state|
      new_state.deal = deal
      new_state.fact = self
    end
    true
  end
end

