
class BalanceSheet < Array
  attr_reader :day

  def initialize(day = DateTime.now)
    @day = day
    Balance.find_all_between_start_and_stop(@day, @day).each { |i| self << i }
    Income.find_all_between_start_and_stop(@day, @day).each { |i| self << i }
  end
end
