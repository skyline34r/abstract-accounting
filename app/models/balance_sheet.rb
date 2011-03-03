
class BalanceSheet < Array
  attr_reader :day, :assets

  def initialize(day = DateTime.now)
    @day = day
    @assets = 0.0
    p = Proc.new do |i|
      self << i
      if i.side == "passive"
        @assets += i.value
      end
    end
    Balance.find_all_between_start_and_stop(@day, @day).each { |i| p.call(i) }
    Income.find_all_between_start_and_stop(@day, @day).each { |i| p.call(i) }
  end
end
