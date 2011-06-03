
class Transcript < Array
  def initialize(deal, start, stop)
    @deal = deal
    @start = start
    @stop = stop
    @total_debits = 0.0
    @total_debits_value = 0.0
    @total_debits_diff = 0.0
    @total_credits = 0.0
    @total_credits_value = 0.0
    @total_credits_diff = 0.0
    load_list
    load_diffs
  end
  attr_reader :deal, :start, :stop, :opening, :closing
  attr_reader :total_debits, :total_debits_value, :total_debits_diff
  attr_reader :total_credits, :total_credits_value, :total_credits_diff

  private
  def load_list
    if !@deal.nil?
      @deal.facts(@start, @stop).each do |fact|
        item = fact.txn.nil? ? Txn.new(:fact => fact, :value => 0, :earnings => 0) : fact.txn
        if !@deal.income? or item.status == 1
          self << item
          if @deal.income?
            if item.earnings < 0.0
              @total_debits_value -= item.earnings
            else
              @total_credits_value += item.earnings
            end
          else
            if item.fact.to.id == @deal.id
              @total_debits += item.fact.amount
              @total_debits_value += item.value + item.earnings
            elsif item.fact.from.id == @deal.id
              @total_credits += item.fact.amount
              @total_credits_value += item.value
            end
          end
        end
      end
    end
  end
  def load_diffs
    if !@deal.nil?
      (if @deal.income?
        Income.find_all_between_start_and_stop(@start - 1, @stop)
      else
        @deal.balance_range(@start - 1, @stop)
      end).each do |balance|
        if balance.start < @start
          @opening = balance
        else
          @closing = balance if balance.paid.nil? or balance.paid > @stop
          @total_debits_diff += balance.debit_diff
          @total_credits_diff += balance.credit_diff
        end
      end
    end
  end
end
