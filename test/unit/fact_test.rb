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
    fact1.to = deals(:equityshare1)
    fact1.from = deals(:equityshare2)
    fact1.resource = fact1.from.take
    assert !fact1.valid?, "Fact should not be valid"
    fact1.to = deals(:bankaccount)
    assert fact1.save, "Fact not saved"

#    f = Fact.find(fact1.id)
#    pp f.from.state(f.day)
#    pp f.to.state(f.day)
#    assert_equal "passive", f.from.state(f.day).side,
#      "From state side is no passive"
#    assert_equal 30000, f.from.state(f.day).amount,
#      "From state amount is not equal to 30000"
#    assert_equal "active", f.to.state(f.day).side,
#      "To state side is no active"
#    assert_equal 300, f.to.state(f.day).amount,
#      "To state amount is not equal to 300"
  end
end
