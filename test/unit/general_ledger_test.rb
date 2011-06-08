require "test_helper"

class GeneralLedgerTest < ActiveSupport::TestCase
  test "check general ledger without saved txns" do
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

    gl = GeneralLedger.new
    assert_equal 0, gl.length, "Wrong transcript count"

    t = Txn.new(:fact => Fact.new(:amount => 310.0,
              :day => DateTime.civil(2011, 6, 6, 12, 0, 0),
              :from => exchange,
              :to => keep,
              :resource => exchange.take))
    assert t.fact.save, "Fact is not saved"

    gl = GeneralLedger.new
    assert_equal 1, gl.length, "Wrong transcript count"
    assert_equal t.fact.id, gl[0].fact.id, "Wrong fact"
    assert_equal 0.0, gl[0].value, "Wrong txn value"
    assert_equal 0.0, gl[0].earnings, "Wrong txn earnings"

    assert t.save, "Txn is not saved"

    gl = GeneralLedger.new
    assert_equal 1, gl.length, "Wrong transcript count"
    assert_equal t.fact.id, gl[0].fact.id, "Wrong fact"
    assert_equal 310.0, gl[0].value, "Wrong txn value"
    assert_equal 0.0, gl[0].earnings, "Wrong txn earnings"
  end
end
