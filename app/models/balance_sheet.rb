
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
    Balance.find_all_between_start_and_stop(@day, @day).each { |i| p.call(i) }
    Income.find_all_between_start_and_stop(@day, @day).each { |i| p.call(i) }
  end
end
