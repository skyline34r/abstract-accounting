require "state_action"
require "closable"

class Balance < ActiveRecord::Base
  validates :amount, :value, :start, :side, :deal, :presence => true
  validates_inclusion_of :side, :in => ["passive", "active"] #[1, 0]
  validates_uniqueness_of :start, :scope => :deal_id
  belongs_to :deal
  
  after_initialize :balance_init
  before_save :balance_save

  def Balance.open
    Balance.find_all_by_paid nil
  end

  def self.find_all_between_start_and_stop(start, stop)
    Balance.where("start <= ? AND (paid > ? OR paid IS NULL)",
      DateTime.new(stop.year, stop.month, stop.day) + 1,
      DateTime.new(start.year, start.month, start.day))
  end

  def txn(aTxn)
    return nil if self.deal.nil?
    return nil if aTxn.nil?
    return nil if aTxn.fact.nil?

    #TODO: separate quote initialization
    #TODO: add quote instead of checking currency
    @credit = if self.deal.give.instance_of?(Money) and
        !self.deal.give.quote.nil?
      self.deal.give.quote.rate
    elsif !Chart.first.nil? and self.deal.give == Chart.first.currency
      1.0
    else
      0.0
    end
    @debit = if self.deal.take.instance_of?(Money) and
        !self.deal.take.quote.nil?
      self.deal.take.quote.rate
    elsif !Chart.first.nil? and self.deal.take == Chart.first.currency
      1.0
    else
      0.0
    end

    if init_from_fact(aTxn.fact)
      self.start = aTxn.fact.day
      val = nil
      val = update_value(aTxn.value)
      self.value = value_i
      if !val.nil?
        arr = Array.new
        arr[0] = val
        arr[1] = !val.accounting_zero?
        if @fact_side == "active" && !@debit.zero? &&
            self.deal.take != self.deal.give
          arr[1] = true
        end
        return arr
      end
    end
    return nil
  end

  include Closable
  include StateAction

  protected #TODO: Replace default method value
  def value_i()
    return self.value if self.deal.nil?
    if self.side == "passive"
      return !@debit.zero? ?
        (self.amount * @debit).accounting_norm : self.value
    end
    return !@credit.zero? ?
        (self.amount * @credit).accounting_norm : self.value
  end

  private
  def balance_save()
    self.value = self.value_i()
  end

  def balance_init()
    self.do_init()
    self.value ||= 0.0 if self.attributes.has_key?('value')
    @debit = 0.0
    @credit = 0.0
    @old_value = 0.0
    @old_amount = 0.0
    @fact_side = nil
  end

  def update_value(aValue)
    return nil if aValue.nil?
    if !@fact_side.nil?
      if @fact_side == "passive"
        if self.side == "passive"
          if !@debit.zero?
            self.value = (self.amount * @debit).accounting_norm
          else
            raise "Old value(" + @old_value.to_s +
              ") is great then zero" if @old_value < 0.0
            raise "Invalid old value" if @old_amount.zero?
            self.value =
              (@old_value * self.amount / @old_amount).accounting_norm
          end
          return @old_value - self.value
        else
          if !@credit.zero?
            self.value = (self.amount * @credit).accounting_norm
          else
            raise "Invalid debit value" if @debit.zero?
            self.value = (self.amount * @debit * self.deal.rate).accounting_norm
          end
          return self.value - @old_value
        end
      else
        if self.side == "passive"
          if !@debit.zero?
            self.value = (self.amount * @debit).accounting_norm
            return self.value - @old_value - aValue
          else
            raise "Invalid argument aValue" if aValue.zero?
            self.value = @old_value + aValue
          end
        else
          if !@credit.zero?
            self.value = (self.amount * @credit).accounting_norm
          else
            raise "Old value is great then zero" if @old_value < 0.0
            raise "Invalid old value" if @old_amount.zero?
            self.value =
              (@old_value * self.amount / @old_amount).accounting_norm
          end
          return @old_value - self.value - aValue
        end
      end
    else
      return nil
    end
    return nil
  end
end
