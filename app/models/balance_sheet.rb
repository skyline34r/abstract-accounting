
class BalanceSheet < Array
  attr_reader :day, :assets, :liabilities

  def initialize(day = DateTime.now)
    @day = day
    @assets = 0.0
    @liabilities = 0.0
    p = Proc.new do |i|
      self << i
      if i.side == "passive"
        @assets += i.value
      else
        @liabilities += i.value
      end
    end
    proc_fact = Proc.new do |state|
      if !state.deal.nil?
        b = state.deal.balances.where("start = ?", state.start)
        b = b.first if b.length > 0
        if b.nil?
          b = Balance.new :amount => state.amount,
            :value => 0.0,
            :start => state.start,
            :paid => state.paid,
            :side => state.side,
            :deal => state.deal
        end
        p.call b if b.paid.nil? or b.paid > @day
      end
    end
    State.find_all_between_start_and_stop(@day, @day).each { |i| proc_fact.call(i) }
    Income.find_all_between_start_and_stop(@day, @day).each { |i| p.call(i) }
  end
end
