class Quote < ActiveRecord::Base
  validates :money, :day, :rate, :diff, :presence => true
  validates_uniqueness_of :money_id, :scope => :day
  belongs_to :money

  after_initialize :do_initialize
  before_save :do_before_save

  private
  def do_initialize
    self.diff ||= 0.0 if new_record?
  end

  def do_before_save
    if !self.money.deal_gives.nil? and !self.money.deal_gives.empty?
      self.money.deal_gives.each do |deal|
        b = deal.balance
        if !b.nil? and b.side == "active"
          self.diff += -(b.amount * self.rate).accounting_norm +
            (b.amount * self.money.quote.rate).accounting_norm
        end
      end
    end
    if !self.diff.accounting_zero?
      income = Income.new
      income.quote = self
      income.save!
    end
    true
  end
end
