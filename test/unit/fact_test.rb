require 'test_helper'

class FactTest < ActiveSupport::TestCase
  test "Store states" do
    s = State.new
    assert s.side == "active", "State is not initialized"
    assert s.invalid?, "Empty state is valid"
    s.deal = Deal.first
    assert s.invalid?, "State with deal is valid"
    s.start = DateTime.civil(2011, 1, 8)
    s.amount = 5000
    s.side = "passive"
    assert s.valid?, "State is invalid"
    s.side = "passive2"
    assert s.invalid?, "State with wrong side is valid"
    s.side = "active"
    assert s.save, "State is not saved"

    assert_equal s, Deal.first.state(s.start),
      "State from first deal is not equal saved state"

    s.destroy
    assert_equal 0, State.all.count, "State is not deleted"
  end

  test "Store facts" do
    fact1 = Fact.new :amount => 100000.0,
      :day => DateTime.civil(2007, 8, 27, 12, 0, 0)
    assert fact1.invalid?, "Invalid fact"
    fact1.to = deals(:equityshare1)
    fact1.from = deals(:equityshare2)
    fact1.resource = fact1.from.take
    assert !fact1.valid?, "Fact should not be valid"
    fact1.to = deals(:bankaccount)
    assert fact1.save, "Fact not saved"
  end

  test "store fact with old date" do
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

    f = Fact.new(:amount => 310.0,
              :day => DateTime.civil(2011, 6, 6, 12, 0, 0),
              :from => exchange,
              :to => keep,
              :resource => exchange.take)
    assert f.save, "Fact is not saved"

    s = exchange.state
    assert_equal 10.0, s.amount, "Wrong amount"
    assert_equal f.day, s.start, "Wrong day"
    assert s.paid.nil?, "Wrong paid"
    s = keep.state
    assert_equal 310.0, s.amount, "Wrong amount"
    assert_equal f.day, s.start, "Wrong day"
    assert s.paid.nil?, "Wrong paid"

    f = Fact.new(:amount => 620.0,
              :day => DateTime.civil(2011, 6, 7, 12, 0, 0),
              :from => exchange,
              :to => keep,
              :resource => exchange.take)
    assert f.save, "Fact is not saved"

    s = exchange.state
    assert_equal 30.0, s.amount, "Wrong amount"
    assert_equal f.day, s.start, "Wrong day"
    assert s.paid.nil?, "Wrong paid"
    assert_equal 2, exchange.states(true).length, "Wrong states count"
    s = exchange.states[0]
    assert_equal 10.0, s.amount, "Wrong amount"
    assert_equal DateTime.civil(2011, 6, 6, 12, 0, 0), s.start, "Wrong day"
    assert_equal f.day, s.paid, "Wrong paid"
    s = keep.state
    assert_equal 930.0, s.amount, "Wrong amount"
    assert_equal f.day, s.start, "Wrong day"
    assert s.paid.nil?, "Wrong paid"
    assert_equal 2, keep.states.length, "Wrong states count"
    s = keep.states[0]
    assert_equal 310.0, s.amount, "Wrong amount"
    assert_equal DateTime.civil(2011, 6, 6, 12, 0, 0), s.start, "Wrong day"
    assert_equal f.day, s.paid, "Wrong paid"

    assert_raise ActiveRecord::RecordInvalid do
      Fact.new(:amount => 930.0,
                :day => DateTime.civil(2011, 6, 6, 12, 0, 0),
                :from => exchange,
                :to => keep,
                :resource => exchange.take).save
    end
    s = exchange.state
    assert_equal 30.0, s.amount, "Wrong amount"
    assert_equal f.day, s.start, "Wrong day"
    assert s.paid.nil?, "Wrong paid"
    assert_equal 2, exchange.states(true).length, "Wrong states count"
    s = exchange.states[0]
    assert_equal 10.0, s.amount, "Wrong amount"
    assert_equal DateTime.civil(2011, 6, 6, 12, 0, 0), s.start, "Wrong day"
    assert_equal f.day, s.paid, "Wrong paid"
    s = keep.state
    assert_equal 930.0, s.amount, "Wrong amount"
    assert_equal f.day, s.start, "Wrong day"
    assert s.paid.nil?, "Wrong paid"
    assert_equal 2, keep.states.length, "Wrong states count"
    s = keep.states[0]
    assert_equal 310.0, s.amount, "Wrong amount"
    assert_equal DateTime.civil(2011, 6, 6, 12, 0, 0), s.start, "Wrong day"
    assert_equal f.day, s.paid, "Wrong paid"

    f = Fact.new(:amount => 930.0,
              :day => DateTime.civil(2011, 6, 7, 12, 0, 0),
              :from => exchange,
              :to => keep,
              :resource => exchange.take)
    assert f.save, "Fact is not saved"

    s = exchange.state
    assert_equal 60.0, s.amount, "Wrong amount"
    assert_equal f.day, s.start, "Wrong day"
    assert s.paid.nil?, "Wrong paid"
    assert_equal 2, exchange.states.length, "Wrong states count"
    s = exchange.states[0]
    assert_equal 10.0, s.amount, "Wrong amount"
    assert_equal DateTime.civil(2011, 6, 6, 12, 0, 0), s.start, "Wrong day"
    assert_equal f.day, s.paid, "Wrong paid"
    s = keep.state
    assert_equal 1860.0, s.amount, "Wrong amount"
    assert_equal f.day, s.start, "Wrong day"
    assert s.paid.nil?, "Wrong paid"
    assert_equal 2, keep.states.length, "Wrong states count"
    s = keep.states[0]
    assert_equal 310.0, s.amount, "Wrong amount"
    assert_equal DateTime.civil(2011, 6, 6, 12, 0, 0), s.start, "Wrong day"
    assert_equal f.day, s.paid, "Wrong paid"
  end
end
