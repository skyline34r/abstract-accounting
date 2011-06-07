require "test_helper"

class BalanceSheetTest < ActiveSupport::TestCase
  test "check balance sheet loaded for only facts" do
    exchange = Deal.new :tag => "exchange money",
      :entity => entities(:sbrfbank),
      :give => money(:eur),
      :take => money(:rub),
      :rate => 31.0
    keep = Deal.new :tag => "money keep",
      :entity => entities(:sbrfbank),
      :give => money(:rub),
      :take => money(:rub),
      :rate => 1.0
    assert exchange.save, "Deal is not saved"
    assert keep.save, "Deal is not saved"

    bs = BalanceSheet.new DateTime.now
    assert_equal 0, bs.length, "Wrong balances count"

    t = Txn.new(:fact => Fact.new(:amount => 310.0,
              :day => DateTime.civil(2011, 6, 6, 12, 0, 0),
              :from => exchange,
              :to => keep,
              :resource => exchange.take))
    assert t.fact.save, "Fact is not saved"

    bs = BalanceSheet.new DateTime.now
    assert_equal 2, bs.length, "Wrong balances count"
    check_balance bs[0],
                 10.0,
                 0.0,
                 "active" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    check_balance bs[1],
                 310.0,
                 0.0,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    assert t.save, "Txn is not saved"

    bs = BalanceSheet.new DateTime.now
    assert_equal 2, bs.length, "Wrong balances count"
    check_balance bs[0],
                 10.0,
                 310.0,
                 "active" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    check_balance bs[1],
                 310.0,
                 310.0,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
  end

  def check_balance b, amount, value, side
    yield(false, b.nil?, "Balance is nil")
    yield(amount, b.amount, "Wrong balance amount")
    yield(value, b.value, "Wrong balance value")
    yield(side, b.side, "Wrong balance side")
  end
end