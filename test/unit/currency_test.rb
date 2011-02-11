require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
  def setup
    #money
    @cf = Money.new :alpha_code => "cf", :num_code => 1
    @cf.save
    @c1 = Money.new :alpha_code => "c1", :num_code => 2
    @c1.save
    @c2 = Money.new :alpha_code => "c2", :num_code => 3
    @c2.save
    #assets
    @y = Asset.new :tag => "y"
    @y.save
    @x = Asset.new :tag => "x"
    @x.save
    #entities
    @B = Entity.new :tag => "B"
    @B.save
    @S1 = Entity.new :tag => "S1"
    @S1.save
    @S2 = Entity.new :tag => "S2"
    @S2.save
    @P1 = Entity.new :tag => "P1"
    @P1.save
    @P2 = Entity.new :tag => "P2"
    @P2.save
    @K = Entity.new :tag => "K"
    @K.save
    #flows
    @af = Deal.new :tag => "af",
      :entity => @B,
      :give => @cf,
      :take => @cf,
      :rate => 1.0
    @af.save
    @a1 = Deal.new :tag => "a1",
      :entity => @B,
      :give => @c1,
      :take => @c1,
      :rate => 1.0
    @a1.save
    @a2 = Deal.new :tag => "a2",
      :entity => @B,
      :give => @c2,
      :take => @c2,
      :rate => 1.0
    @a1.save
    @dx = Deal.new :tag => "dx",
      :entity => @K,
      :give => @x,
      :take => @x,
      :rate => 1.0
    @dx.save
    @dy = Deal.new :tag => "dy",
      :entity => @K,
      :give => @y,
      :take => @y,
      :rate => 1.0
    @dy.save
    @bx1 = Deal.new :tag => "bx1",
      :entity => @S1,
      :give => @c1,
      :take => @x,
      :rate => (1.0 / 100.0)
    @bx1.save
    @by2 = Deal.new :tag => "by2",
      :entity => @S2,
      :give => @cf,
      :take => @y,
      :rate => (1.0 / 200.0)
    @by2.save
    @sx1 = Deal.new :tag => "sx1",
      :entity => @P1,
      :give => @x,
      :take => @cf,
      :rate => 200.0
    @sx1.save
    @sy2 = Deal.new :tag => "sy2",
      :entity => @P2,
      :give => @y,
      :take => @c2,
      :rate => 150.0
    @sy2.save
  end

  test "currency" do
    check_quote
    purchase
    rate_change_before_income
  end

  private
  def check_quote
    q = Quote.new :money => @cf,
      :rate => 1.0,
      :day => DateTime.civil(2008, 3, 24, 12, 0, 0)
    assert_equal 0.0, q.diff, "Quote diff is not initialized"
    assert q.valid?, "Quote is not valid"
    assert q.save, "Quote is not saved"
    assert_equal 0.0, Quote.find(q.id).diff, "Quote diff is not saved"

    assert Quote.new(:money => @c1, :rate => 1.5,
      :day => DateTime.civil(2008, 3, 24, 12, 0, 0)).save, "Quote is not saved"
  end

  def purchase
    t = Txn.new(:fact => Fact.new(:amount => 300.0,
              :day => DateTime.civil(2008, 3, 24, 12, 0, 0),
              :from => @bx1,
              :to => @dx,
              :resource => @bx1.take))
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert_equal 2, Balance.all.count, "Balance count is not equal to 2"

    b = t.from_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 30000.0, b.amount, "Wrong balance amount"
    assert_equal 45000.0, b.value, "Wrong balance value"
    assert_equal @bx1, b.deal, "Wrong balance deal"
    assert_equal "active", b.side, "Wrong balance side"

    b = t.to_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 300.0, b.amount, "Wrong balance amount"
    assert_equal 45000.0, b.value, "Wrong balance value"
    assert_equal @dx, b.deal, "Wrong balance deal"
    assert_equal "passive", b.side, "Wrong balance side"
  end

  def rate_change_before_income
    assert_equal @c1.quotes.first, @c1.quote, "Maximum quote for money is wrong"

    assert (q = Quote.new(:money => @c1, :rate => 1.6,
      :day => DateTime.civil(2008, 3, 25, 12, 0, 0))).save, "Quote is not saved"

    assert_equal q, @c1.quote, "Maximum quote for money is wrong"
    assert_equal -3000.0, q.diff, "Quote diff is wrong"

    assert_equal 1, Income.open.count, "Open incomes count is wrong"
    assert_equal "passive", Income.open.first.side, "Open income wrong side"
    assert_equal 0.0, Income.open.first.value + q.diff,
      "Open income wrong value"
  end
end
