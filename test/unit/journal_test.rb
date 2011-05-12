require 'test_helper'

class JournalTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "must be saved when fact is saved" do
    assert_equal 0, Journal.all.count, "Wrong journal count"

    User.current = entities(:sergey)

    fact1 = Fact.new :amount => 100000.0,
      :day => DateTime.civil(2007, 8, 27, 12, 0, 0)
    fact1.to = deals(:bankaccount)
    fact1.from = deals(:equityshare2)
    fact1.resource = fact1.from.take
    assert fact1.save, "Fact not saved"

    assert_equal 1, Journal.all.count, "Wrong journal count"
    assert_equal fact1, Journal.first.fact, "Wrong journal fact"
    assert !Journal.first.created_at.nil?, "Wrong journal created at"
    assert_equal User.current, Journal.first.created_by, "Journal wrong created_by"
  end
end
