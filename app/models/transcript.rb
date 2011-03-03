
class Transcript < Array
  def initialize(deal, start, stop)
    @deal = deal
    @start = start
    @stop = stop
    @total_debits = 0.0
    @total_debits_value = 0.0
    @total_credits = 0.0
    @total_credits_value = 0.0
    load_list
    load_diffs
  end
  attr_reader :deal, :start, :stop, :opening, :closing
  attr_reader :total_debits, :total_debits_value
  attr_reader :total_credits, :total_credits_value

  private
  def load_list
    if !@deal.nil?
      @deal.txns(@start, @stop).each do |item|
        self << item
        if item.fact.to == @deal
          @total_debits += item.fact.amount
          @total_debits_value += item.value + item.earnings
        elsif item.fact.from == @deal
          @total_credits += item.fact.amount
          @total_credits_value += item.value
        end
      end
    end
  end
  def load_diffs
    if !@deal.nil?
      @deal.balance_range(@start - 1, @stop).each do |balance|
        @opening = balance if balance.start < @start
        @closing = balance if balance.paid.nil? or balance.paid > @stop
      end
    end
  end
end
