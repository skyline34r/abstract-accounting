
class Transcript < Array
  def initialize(deal, start, stop)
    @deal = deal
    @start = start
    @stop = stop
    load_list
    load_diffs
  end
  attr_reader :deal, :start, :stop, :opening, :closing

  private
  def load_list
    if !@deal.nil?
      @deal.txns(@start, @stop).each do |item|
        self << item
      end
    end
  end
  def load_diffs
    if !@deal.nil?
      @deal.balance_range(@start, @stop).each do |balance|
        @opening = balance if balance.paid.nil?
        @closing = balance if !balance.paid.nil?
      end
    end
  end
end
