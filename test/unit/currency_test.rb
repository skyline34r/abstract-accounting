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
    sale_advance
    forex_sale
    rate_change
    forex_sale_after_rate_change
    transfer_rollback

    test_balance_sheet
    test_transcript
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

    assert_equal 0, Income.all.count, "Wrong income count"

    assert (q = Quote.new(:money => @c1, :rate => 1.6,
      :day => DateTime.civil(2008, 3, 25, 12, 0, 0))).save, "Quote is not saved"

    assert_equal q, @c1.quote, "Maximum quote for money is wrong"
    assert_equal -3000.0, q.diff, "Quote diff is wrong"

    assert_equal 1, Income.all.count, "Wrong income count"
    assert_equal 1, Income.open.count, "Open incomes count is wrong"
    assert_equal "passive", Income.open.first.side, "Open income wrong side"
    assert_equal 0.0, Income.open.first.value + q.diff,
      "Open income wrong value"
  end

  def sale_advance
    assert @c2.quote.nil?, "Money c2 quote is not nil"

    assert (q = Quote.new(:money => @c2, :rate => 2.0,
      :day => DateTime.civil(2008, 3, 25, 12, 0, 0))).save, "Quote is not saved"

    t = Txn.new(:fact => Fact.new(:amount => 60000.0,
              :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
              :from => @sy2,
              :to => @a2,
              :resource => @sy2.take))
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    b = t.from_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 400.0, b.amount, "Wrong balance amount"
    assert_equal 120000.0, b.value, "Wrong balance value"
    assert_equal @sy2, b.deal, "Wrong balance deal"
    assert_equal "active", b.side, "Wrong balance side"

    b = t.to_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 60000.0, b.amount, "Wrong balance amount"
    assert_equal 120000.0, b.value, "Wrong balance value"
    assert_equal @a2, b.deal, "Wrong balance deal"
    assert_equal "passive", b.side, "Wrong balance side"
  end

  def forex_sale
    #pay for forex deal 1
    assert (f1 = Deal.new(:tag => "f1",
        :entity => @B, :give => @c2, :take => @cf, :rate => 2.1)).save,
      "Deal is not saved"

    t = Txn.new(:fact => Fact.new(:amount => 10000.0,
              :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
              :from => @a2,
              :to => f1,
              :resource => @a2.take))
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    b = t.from_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 50000.0, b.amount, "Wrong balance amount"
    assert_equal 100000.0, b.value, "Wrong balance value"
    assert_equal @a2, b.deal, "Wrong balance deal"
    assert_equal "passive", b.side, "Wrong balance side"

    b = t.to_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 21000.0, b.amount, "Wrong balance amount"
    assert_equal 21000.0, b.value, "Wrong balance value"
    assert_equal f1, b.deal, "Wrong balance deal"
    assert_equal "passive", b.side, "Wrong balance side"

    #pay for forex deal 2
    assert (f2 = Deal.new(:tag => "f2",
        :entity => @B, :give => @c2, :take => @cf, :rate => 2.0)).save,
      "Deal is not saved"

    t = Txn.new(:fact => Fact.new(:amount => 10000.0,
              :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
              :from => @a2,
              :to => f2,
              :resource => @a2.take))
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    b = t.from_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 40000.0, b.amount, "Wrong balance amount"
    assert_equal 80000.0, b.value, "Wrong balance value"
    assert_equal @a2, b.deal, "Wrong balance deal"
    assert_equal "passive", b.side, "Wrong balance side"

    b = t.to_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 20000.0, b.amount, "Wrong balance amount"
    assert_equal 20000.0, b.value, "Wrong balance value"
    assert_equal f2, b.deal, "Wrong balance deal"
    assert_equal "passive", b.side, "Wrong balance side"

    #pay for forex deal 3
    assert (f3 = Deal.new(:tag => "f3",
        :entity => @B, :give => @c2, :take => @cf, :rate => 1.95)).save,
      "Deal is not saved"

    t = Txn.new(:fact => Fact.new(:amount => 10000.0,
              :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
              :from => @a2,
              :to => f3,
              :resource => @a2.take))
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    b = t.from_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 30000.0, b.amount, "Wrong balance amount"
    assert_equal 60000.0, b.value, "Wrong balance value"
    assert_equal @a2, b.deal, "Wrong balance deal"
    assert_equal "passive", b.side, "Wrong balance side"

    b = t.to_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 19500.0, b.amount, "Wrong balance amount"
    assert_equal 19500.0, b.value, "Wrong balance value"
    assert_equal f3, b.deal, "Wrong balance deal"
    assert_equal "passive", b.side, "Wrong balance side"
  end

  def rate_change
    assert_equal 1, Income.all.count, "Wrong income count"

    assert (q = Quote.new(:money => @c2, :rate => 2.1,
      :day => DateTime.civil(2008, 3, 31, 12, 0, 0))).save, "Quote is not saved"

    assert_equal q, @c2.quote, "Maximum quote for money is wrong"
    assert_equal 3000.0, q.diff, "Quote diff is wrong"

    assert_equal 2, Income.all.count, "Wrong income count"
    assert_equal 1, Income.open.count, "Wrong open incomes count"
    assert_equal "active", Income.open.first.side, "Invalid open income side"
    assert_equal 500.0, Income.open.first.value, "Invalid open income value"
  end

  def forex_sale_after_rate_change
    #pay for forex deal 4
    assert (f4 = Deal.new(:tag => "f4",
        :entity => @B, :give => @c2, :take => @c1, :rate => (2.1 / 1.6))).save,
      "Deal is not saved"

    t = Txn.new(:fact => Fact.new(:amount => 10000.0,
              :day => DateTime.civil(2008, 3, 31, 12, 0, 0),
              :from => @a2,
              :to => f4,
              :resource => @a2.take))
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    b = t.from_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 20000.0, b.amount, "Wrong balance amount"
    assert_equal 42000.0, b.value, "Wrong balance value"
    assert_equal @a2, b.deal, "Wrong balance deal"
    assert_equal "passive", b.side, "Wrong balance side"

    b = t.to_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 13125.0, b.amount, "Wrong balance amount"
    assert_equal 21000.0, b.value, "Wrong balance value"
    assert_equal f4, b.deal, "Wrong balance deal"
    assert_equal "passive", b.side, "Wrong balance side"
  end

  def transfer_rollback
    #initialize
    assert (c3 = Money.new(:alpha_code => "c3", :num_code => 4)).save,
      "Mone is not saved"
    assert (by3 = Deal.new(:tag => "by3", :give => c3, :take => @y,
        :entity => @S2, :rate => (1.0 / 200.0))).save, "Deal is not saved"
    assert Quote.new(:rate => 0.8, :money => c3,
      :day => DateTime.civil(2008, 4, 14, 12, 0, 0)).save, "Quote is not saved"

    assert (f = Fact.new(:amount => 100.0,
              :day => DateTime.civil(2008, 4, 11, 12, 0, 0),
              :from => by3,
              :to => @dy,
              :resource => by3.take)).save, "Fact is not saved"

    assert_equal 7, Fact.all.count, "Wrong fact count"
    assert_equal 10, State.open.count, "Wrong open states count"

    f.destroy
    assert_equal 6, Fact.all.count, "Wrong fact count"
    assert_equal 8, State.open.count, "Wrong open states count"
  end

  def test_balance_sheet
    b = (BalanceSheet.new)[0]
    assert !b.nil?, "Balance is nil"
    assert_equal 30000.0, b.amount, "Wrong balance amount"
    assert_equal 45000.0, b.value, "Wrong balance value"
    assert_equal "active", b.side, "Wrong balance side"
    assert_equal @bx1, b.deal, "Wrong balance deal"
  end

  def test_transcript
    tr = Transcript.new(@a2,
      DateTime.civil(2008, 3, 25, 12, 0, 0),
      DateTime.civil(2008, 3, 31, 12, 0, 0))
    assert_equal 3000.0, tr.total_debits_diff,
      "Wrong total debits diff in transcript"
    assert_equal 0.0, tr.total_credits_diff,
      "Wrong total credits diff in transcript"
    assert_equal 60000.0, tr.total_debits,
      "Wrong total debits in transcript"
    assert_equal 40000.0, tr.total_credits,
      "Wrong total credits in transcript"
    assert_equal 120000.0, tr.total_debits_value,
      "Wrong total debits value in transcript"
    assert_equal 81000.0, tr.total_credits_value,
      "Wrong total credits value in transcript"


    tr = Transcript.new(@bx1,
      DateTime.civil(2008, 3, 24, 12, 0, 0),
      DateTime.civil(2008, 3, 31, 12, 0, 0))
    assert_equal 0.0, tr.total_debits_diff,
      "Wrong total debits diff in transcript"
    assert_equal 3000.0, tr.total_credits_diff,
      "Wrong total credits diff in transcript"
    assert_equal 0.0, tr.total_debits,
      "Wrong total debits in transcript"
    assert_equal 300, tr.total_credits,
      "Wrong total credits in transcript"
    assert_equal 0.0, tr.total_debits_value,
      "Wrong total debits value in transcript"
    assert_equal 45000.0, tr.total_credits_value,
      "Wrong total credits value in transcript"

    tr = Transcript.new(Deal.income,
      DateTime.civil(2008, 3, 24, 12, 0, 0),
      DateTime.civil(2008, 3, 31, 12, 0, 0))
    assert_equal 3000.0, tr.total_debits_diff,
      "Wrong total debits diff in transcript"
    assert_equal 3000.0, tr.total_credits_diff,
      "Wrong total credits diff in transcript"
    assert_equal 500.0, tr.total_debits_value,
      "Wrong total debits value in transcript"
    assert_equal 1000.0, tr.total_credits_value,
      "Wrong total credits value in transcript"
  end
end
