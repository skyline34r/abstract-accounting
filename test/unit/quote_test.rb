require "test_helper"

class QuoteTest < ActiveSupport::TestCase
  test "bug with empty quote by money" do
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

    t = Txn.new :fact => Fact.new(:amount => 310.0,
              :day => DateTime.civil(2011, 6, 6, 12, 0, 0),
              :from => exchange,
              :to => keep,
              :resource => exchange.take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert Quote.new(:money => money(:eur),
                     :day => DateTime.civil(2011, 6, 7, 12, 0, 0),
                     :rate => 25.0).save, "Cann't save quote"
  end

  test "check save quote for money as take resource" do
    exchange = Deal.new :tag => "exchange money",
      :entity => entities(:sbrfbank),
      :give => money(:rub),
      :take => money(:eur),
      :rate => 0.015
    keep = Deal.new :tag => "money keep",
      :entity => entities(:sbrfbank),
      :give => money(:rub),
      :take => money(:rub),
      :rate => 1.0
    assert exchange.save, "Deal is not saved"
    assert keep.save, "Deal is not saved"

    t = Txn.new :fact => Fact.new(:amount => 310.0,
              :day => DateTime.civil(2011, 6, 6, 12, 0, 0),
              :from => keep,
              :to => exchange,
              :resource => exchange.give)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert Quote.new(:money => money(:eur),
                     :day => DateTime.civil(2011, 6, 7, 12, 0, 0),
                     :rate => 25.0).save, "Cann't save quote"
  end
end
