require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "float accounting zero" do
    assert 0.0.accounting_zero?, "0.0 is not zero"
    assert !0.00009.accounting_zero?, "0.00009 is zero"
    assert !-0.00009.accounting_zero?, "-0.00009 is zero"
    assert -0.000071.accounting_zero?, "-0.000071 is not zero"
    assert 0.000081.accounting_zero?, "0.000081 is not zero"
    assert !0.03.accounting_zero?, "0.03 is zero"
  end
  test "float accounting round64" do
    assert_equal 100.0, 100.05.accounting_round64,
      "100.05 accounting round fail"
    assert_equal -100.0, -100.05.accounting_round64,
      "-100.05 accounting round fail"
    assert_equal 101.0, 100.8.accounting_round64,
      "100.8 accounting round fail"
    assert_equal -101.0, -100.8.accounting_round64,
      "-100.8 accounting round fail"
  end
  test "float accounting norm" do
    assert_equal 1.0, 1.0005.accounting_norm,
      "1.0005 accounting round fail"
    assert_equal -1.0, -1.0005.accounting_norm,
      "-1.0005 accounting round fail"
    assert_equal 1.01, 1.008.accounting_norm,
      "1.008 accounting round fail"
    assert_equal -1.01, -1.008.accounting_norm,
      "-1.008 accounting round fail"
  end
  test "float accounting negative" do
    assert !0.0.accounting_negative?, "0.0 is negative"
    assert !0.00009.accounting_negative?, "0.00009 is negative"
    assert -0.00009.accounting_negative?, "-0.00009 is not negative"
    assert !-0.000071.accounting_negative?, "-0.000071 is negative"
    assert !0.000081.accounting_negative?, "0.000081 is negative"
    assert !0.03.accounting_negative?, "0.03 is negative"
    assert -0.03.accounting_negative?, "-0.03 is not negative"
  end

  test "balance should save" do
    b = Balance.new
    assert_equal "active", b.side, "Balance is not initialized"
    assert b.invalid?, "Empty Balance is valid"
    b.deal = Deal.first
    assert b.invalid?, "Balance with deal is valid"
    b.start = DateTime.civil(2011, 1, 8)
    b.amount = 5000
    b.side = "passive"
    b.value = 54.0
    assert b.valid?, "Balance is invalid"
    b.side = "passive2"
    assert b.invalid?, "Balance with wrong side is valid"
    b.side = "active"
    assert b.save, "Balance is not saved"
    assert_equal 1, Balance.all.count, "Balance is not deleted"

    assert Balance.new(:deal => Deal.first, :amount => 51, :value => 43,
      :side => "passive", :start => DateTime.civil(2011, 1, 8)).invalid?,
      "Balance with not unique deal and start is valid"

    b.destroy
    assert_equal 0, Balance.all.count, "Balance is not deleted"
  end

  test "account test" do
    facts = init_facts
    assert !Fact.pendings.nil?, "Pending facts is nil"

    facts.count.times do
      assert_equal facts.count, Fact.pendings.count,
        "Wrong pending facts count"
      assert_equal facts.first, Fact.pendings.first,
        "Pending fact is wrong"

      pendingFact = Fact.pendings.first
      t = Txn.new :fact => pendingFact
      assert t.valid?, "Transaction is not valid"
      assert t.save, "Txn is not saved"

      case facts.count
      when 6
        assert_equal 1, Chart.all.count, "Wrong chart count"
        assert_equal money(:rub), Chart.all.first.currency,
          "Wrong chart currency"

        bfrom = t.from_balance
        assert !bfrom.nil?, "Balance is nil"
        assert_equal pendingFact.from, bfrom.deal, "From balance invalid deal"
        assert_equal pendingFact.from.give, bfrom.resource,
          "From balance invalid resource"
        assert_equal "active", bfrom.side, "From balance invalid side"
        assert_equal pendingFact.amount / deals(:equityshare2).rate, bfrom.amount,
          "From balance amount is not equal"
        assert_equal pendingFact.amount, bfrom.value,
          "From balance value is not equal"
        assert_equal t.from_balance, deals(:equityshare2).balance,
          "Deal balance is wrong"

        bto = t.to_balance
        assert !bto.nil?, "Balance is nil"
        assert_equal pendingFact.to, bto.deal, "To balance invalid deal"
        assert_equal pendingFact.to.take, bto.resource,
          "To balance invalid resource"
        assert_equal "passive", bto.side, "To balance invalid side"
        assert_equal pendingFact.amount, bto.amount,
          "To balance amount is not equal"
        assert_equal pendingFact.amount, bto.value,
          "To balance value is not equal"
      when 5
        assert_equal 3, Balance.all.count, "Balance count is not equal to 3"

        bfrom = t.from_balance
        assert !bfrom.nil?, "Balance is nil"
        assert_equal pendingFact.from, bfrom.deal, "From balance invalid deal"
        assert_equal pendingFact.from.give, bfrom.resource,
          "From balance invalid resource"
        assert_equal "active", bfrom.side, "From balance invalid side"
        assert_equal pendingFact.amount / deals(:equityshare1).rate, bfrom.amount,
          "From balance amount is not equal"
        assert_equal pendingFact.amount, bfrom.value,
          "From balance value is not equal"

        bto = t.to_balance
        assert !bto.nil?, "Balance is nil"
        assert_equal pendingFact.to, bto.deal, "To balance invalid deal"
        assert_equal pendingFact.to.take, bto.resource,
          "To balance invalid resource"
        assert_equal "passive", bto.side, "To balance invalid side"
        assert_equal pendingFact.amount + 100000.0, bto.amount,
          "To balance amount is not equal"
        assert_equal pendingFact.amount + 100000.0, bto.value,
          "To balance value is not equal"
      when 4
        assert_equal 5, Balance.all.count, "Balance count is not equal to 5"

        bfrom = t.from_balance
        assert !bfrom.nil?, "Balance is nil"
        assert_equal pendingFact.from, bfrom.deal, "From balance invalid deal"
        assert_equal pendingFact.from.give, bfrom.resource,
          "From balance invalid resource"
        assert_equal "passive", bfrom.side, "From balance invalid side"
        assert_equal 142000.0 + 100000.0 - pendingFact.amount, bfrom.amount,
          "From balance amount is not equal"
        assert_equal 142000.0 + 100000.0 - pendingFact.amount, bfrom.value,
          "From balance value is not equal"

        bto = t.to_balance
        assert !bto.nil?, "Balance is nil"
        assert_equal pendingFact.to, bto.deal, "To balance invalid deal"
        assert_equal pendingFact.to.take, bto.resource,
          "To balance invalid resource"
        assert_equal "passive", bto.side, "To balance invalid side"
        assert_equal (pendingFact.amount *
            deals(:purchase).rate).accounting_norm, bto.amount,
          "To balance amount is not equal"
        assert_equal pendingFact.amount, bto.value,
          "To balance value is not equal"

        b = deals(:bankaccount).balance nil, DateTime.civil(2007, 8, 29, 12, 0, 1)
        assert !b.nil?, "Balance is nil"
        assert_equal deals(:bankaccount), b.deal, "balance invalid deal"
        assert_equal deals(:bankaccount).take, b.resource,
          "balance invalid resource"
        assert_equal "passive", b.side, "balance invalid side"
        assert_equal 100000.0 + 142000.0, b.amount,
          "balance amount is not equal"
        assert_equal 100000.0 + 142000.0, b.value,
          "balance value is not equal"
      when 3
        assert_equal 7, Balance.all.count, "Balance count is not equal to 7"

        bfrom = t.from_balance
        assert !bfrom.nil?, "Balance is nil"
        assert_equal pendingFact.from, bfrom.deal, "From balance invalid deal"
        assert_equal pendingFact.from.give, bfrom.resource,
          "From balance invalid resource"
        assert_equal "active", bfrom.side, "From balance invalid side"
        assert_equal (pendingFact.amount / deals(:forex).rate).accounting_norm,
          bfrom.amount, "From balance amount is not equal"
        assert_equal (pendingFact.amount / deals(:forex).rate).accounting_norm,
          bfrom.value, "From balance value is not equal"

        bto = t.to_balance
        assert !bto.nil?, "Balance is nil"
        assert_equal pendingFact.to, bto.deal, "To balance invalid deal"
        assert_equal pendingFact.to.take, bto.resource,
          "To balance invalid resource"
        assert_equal "passive", bto.side, "To balance invalid side"
        assert_equal pendingFact.amount, bto.amount,
          "To balance amount is not equal"
        assert_equal (pendingFact.amount / deals(:forex).rate).accounting_norm,
          bto.value, "To balance value is not equal"
      when 2
        assert_equal 6, Balance.all.count, "Balance count is not equal to 6"

        bfrom = t.from_balance
        assert !bfrom.nil?, "Balance is nil"
        assert_equal pendingFact.from, bfrom.deal, "From balance invalid deal"
        assert_equal pendingFact.from.give, bfrom.resource,
          "From balance invalid resource"
        assert_equal "passive", bfrom.side, "From balance invalid side"
        assert_equal 142000.0 + 100000.0 - 70000.0 - pendingFact.amount,
          bfrom.amount, "From balance amount is not equal"
        assert_equal 142000.0 + 100000.0 - 70000.0 - pendingFact.amount,
          bfrom.value, "From balance value is not equal"

        bto = t.to_balance
        assert bto.nil?, "Balance is not nil"
        assert deals(:forex).balance.nil?, "Forex deal balance is not nil"

        assert_equal (1000.0 / deals(:forex).rate).accounting_norm,
          Fact.find(pendingFact.id).txn.value, "Txn value is not equal"

        assert_equal 0, Income.all.count, "Income count is not equal to 0"
      when 1
        b = deals(:bankaccount2).balance
        assert b.nil?, "Balance is not nil"
        b = deals(:forex2).balance
        assert !b.nil?, "Balance is nil"
        assert_equal deals(:forex2), b.deal, "balance invalid deal"
        assert_equal deals(:forex2).take, b.resource,
          "balance invalid resource"
        assert_equal "passive", b.side, "balance invalid side"
        assert_equal pendingFact.amount * deals(:forex2).rate, b.amount,
          "balance amount is not equal"
        assert_equal pendingFact.amount * deals(:forex2).rate, b.value,
          "balance value is not equal"

        assert_equal 1, Income.all.count, "Income count is wrong"
        inc = Income.all.first
        @profit = (pendingFact.amount * (deals(:forex2).rate -
              (1/deals(:forex).rate))).accounting_norm
        assert_equal @profit, inc.value, "Invalid income value"

        assert_equal 0, Fact.pendings.count, "Pending facts count is wrong"
      end
      facts.delete_at(0)
    end

    loss_transaction
    split_transaction
    gain_transaction
    direct_gains_losses
    test_txn_list_by_time_frame_and_deal
  end

  private
  def loss_transaction
     # Settle forex deal #2
    t = Txn.new :fact => Fact.new(:amount => 1000.0 * deals(:forex2).rate,
              :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
              :from => deals(:forex2),
              :to => deals(:bankaccount),
              :resource => deals(:forex2).take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert !Balance.open.nil?, "Open balances is nil"
    assert_equal 4, Balance.open.count, "Open balances count is wrong"

    test_balance deals(:equityshare2).balance,
                 (100000.0 / deals(:equityshare2).rate).accounting_norm,
                 100000.0,
                 "active" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    test_balance deals(:equityshare1).balance,
                 (142000.0 / deals(:equityshare1).rate).accounting_norm,
                 142000.0,
                 "active" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    test_balance deals(:purchase).balance,
                 (70000.0 * deals(:purchase).rate).accounting_norm,
                 70000.0,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    @rubs = 100000.0 + 142000.0 - 70000.0 +
      (1000.0 * (deals(:forex2).rate - 1 / deals(:forex).rate))
    test_balance deals(:bankaccount).balance,
                 @rubs.accounting_norm,
                 @rubs.accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    #forex deal #3
    @forex3 = Deal.new :tag => "forex deal 3",
      :rate => (1 / 34.2),
      :entity => entities(:sbrfbank),
      :give => money(:rub),
      :take => money(:eur)
    assert @forex3.save, "Forex deal 3 is not saved"
    #Pay forex deal #3
    t = Txn.new :fact => Fact.new(
              :amount => (5000.0 / @forex3.rate).accounting_norm,
              :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
              :from => deals(:bankaccount),
              :to => @forex3,
              :resource => deals(:bankaccount).take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert_equal 5, Balance.open.count, "Open balances count is wrong"
    @rubs -= (5000.0 / @forex3.rate).accounting_norm
    test_balance deals(:bankaccount).balance,
                 @rubs.accounting_norm,
                 @rubs.accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    test_balance @forex3.balance,
                 5000.0,
                 (5000.0 / @forex3.rate).accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    #Recieve settlement from forex deal #3
    t = Txn.new :fact => Fact.new(
              :amount => 5000.0,
              :day => DateTime.civil(2007, 9, 4, 12, 0, 0),
              :from => @forex3,
              :to => deals(:bankaccount2),
              :resource => @forex3.take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert_equal 5, Balance.open.count, "Open balances count is wrong"
    assert @forex3.balance.nil?, "Balance is not nil"
    test_balance deals(:bankaccount2).balance,
                 5000.0,
                 (5000.0 / @forex3.rate).accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    #Create flow for office rent
    @landlord = Entity.new :tag => "Audit service"
    assert @landlord.save, "Audit service not saved"
    @rent = Asset.new :tag => "office space"
    assert @rent.save, "Asset not saved"
    @office = Deal.new :tag => "rented office 1",
      :rate => (1 / 2000.0),
      :entity => @landlord,
      :give => money(:rub),
      :take => @rent
    assert @office.save, "Flow is not saved"

    #Accrue office rent for august
    t = Txn.new :fact => Fact.new(
              :amount => 1.0,
              :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
              :from => @office,
              :to => Deal.income,
              :resource => @office.take)
    assert t.fact.valid?, "Fact is not valid"
    assert t.fact.save, "Fact is not saved"

    assert_equal 6, State.open.count, "State count is wrong"
    s = @office.state
    assert !s.nil?, "State is nil"
    assert_equal (1 / @office.rate).accounting_norm, s.amount,
      "State amount is wrong"
    assert_equal money(:rub), s.resource, "State resource is wrong"

    s = deals(:bankaccount).state
    assert !s.nil?, "State is nil"
    assert_equal @rubs.accounting_norm, s.amount,
      "State amount is wrong"
    assert_equal money(:rub), s.resource, "State resource is wrong"

    #Reflect office rent for august
    assert t.save, "Txn is not saved"

    assert_equal 6, Balance.open.count, "Balance count is wrong"
    test_balance t.from_balance,
                 (1 / @office.rate).accounting_norm,
                 (1 / @office.rate).accounting_norm,
                 "active" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    assert t.to_balance.nil?, "To balance is not nil"

    assert_equal 1, Income.open.count, "Income count is wrong"
    @profit -= (1 / @office.rate).accounting_norm
    assert (@profit + Income.open.first.value).accounting_zero?,
      "Income value is wrong"
  end

  def split_transaction
    #Create flow for forex deal #4
    @forex4 = Deal.new :tag => "forex deal 4",
      :rate => 34.95,
      :entity => entities(:sbrfbank),
      :give => money(:eur),
      :take => money(:rub)
    assert @forex4.save, "Flow is not saved"

    #Partially pay forex deal #4
    t = Txn.new :fact => Fact.new(
              :amount => 2000.0,
              :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
              :from => deals(:bankaccount2),
              :to => @forex4,
              :resource => deals(:bankaccount2).take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert_equal 7, Balance.open.count, "Open balances count is wrong"
    @euros = 5000.0 - t.fact.amount
    test_balance deals(:bankaccount2).balance,
                 @euros,
                 (@euros * 34.2).accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    test_balance @forex4.balance,
                 (t.fact.amount * @forex4.rate).accounting_norm,
                 (t.fact.amount * @forex4.rate).accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    assert_equal 1, Income.open.count, "Wrong income count"

    @profit += (34.95 - 34.2) * t.fact.amount
    assert (@profit + Income.open.first.value).accounting_zero?,
      "Wrong income value"

    #Partially receive from forex deal #4
    t = Txn.new :fact => Fact.new(
              :amount => (2500.0 * 34.95),
              :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
              :from => @forex4,
              :to => deals(:bankaccount),
              :resource => @forex4.take)
    assert t.fact.save, "Fact is not saved"
    assert_equal 7, State.open.count, "Wrong open states count"

    s = @forex4.state
    assert !s.nil?, "Forex state is nil"
    assert_equal 2500.0 - 2000.0, s.amount, "Wrong forex state amount"
    assert_equal money(:eur), s.resource, "Wrong forex state resource"

    #Reflect partial revenue from forex deal #4
    assert t.save, "Txn is not saved"

    assert_equal 7, Balance.open.count, "Wrong open balances count"
    test_balance @forex4.balance,
                 2500.0 - 2000.0,
                 ((2500.0 - 2000.0) * 34.95).accounting_norm,
                 "active" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    @rubs += t.fact.amount
    test_balance deals(:bankaccount).balance,
                 @rubs.accounting_norm,
                 @rubs.accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    assert_equal 1, Income.open.count, "Wrong open incomes count"
    assert @profit + Income.open.first.value, "Wrong income value"

    #Fully pay forex deal #4
    t = Txn.new :fact => Fact.new(
              :amount => 600.0,
              :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
              :from => deals(:bankaccount2),
              :to => @forex4,
              :resource => deals(:bankaccount2).take)
    assert t.fact.save, "Fact is not saved"

    assert_equal 7, State.open.count, "Wrong open states count"
    s = @forex4.state
    assert !s.nil?, "Forex state is nil"
    assert_equal (100.0 * 34.95).accounting_norm, s.amount, "Wrong forex state amount"
    assert_equal money(:rub), s.resource, "Wrong forex state resource"

    #Reflect full payment of deal #4
    assert t.save, "Txn is not saved"

    assert_equal 7, Balance.open.count, "Wrong open balances count"
    test_balance @forex4.balance,
                 (100.0 * 34.95).accounting_norm,
                 (100.0 * 34.95).accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    @euros -= 600.0
    test_balance deals(:bankaccount2).balance,
                 (@euros).accounting_norm,
                 (@euros * 34.2).accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    assert_equal 0, Income.open.count, "Wrong open income count"

    @profit += (34.95 - 34.2) * 600.0
  end

  def gain_transaction
    #Recieve settlement from forex deal #4
    t = Txn.new :fact => Fact.new(
              :amount => 100.0 * 34.95,
              :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
              :from => @forex4,
              :to => deals(:bankaccount),
              :resource => @forex4.take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert_equal 6, Balance.open.count, "Wrong open balances count"
    assert @forex4.balance.nil?, "Forex 4 balance is not nil"

    @rubs += 100.0 * 34.95
    test_balance deals(:bankaccount).balance,
                 @rubs.accounting_norm,
                 @rubs.accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    #Settle office rent for Aug and prepay for Sep
    t = Txn.new :fact => Fact.new(
              :amount => 2 * 2000.0,
              :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
              :from => deals(:bankaccount),
              :to => @office,
              :resource => deals(:bankaccount).take)
    assert t.fact.save, "Fact is not saved"
    assert_equal 6, State.open.count, "Open states count is wrong"
    s = @office.state
    assert !s.nil?, "Office state is nil"
    assert_equal 1.0, s.amount, "Wrong forex state amount"
    assert_equal @office.take, s.resource, "Wrong forex state resource"

    #Reflect payment for office
    assert t.save, "Txn is not saved"
    assert_equal 6, Balance.open.count, "Wrong open balances count"
    @rubs -= 2 * 2000.0
    test_balance deals(:bankaccount).balance,
                 @rubs.accounting_norm,
                 @rubs.accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    test_balance @office.balance,
                 1.0,
                 2000.0,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    assert_equal 0, Income.open.count, "Wrong open incomes count"

    #Direct monetary loss
    t = Txn.new :fact => Fact.new(
              :amount => 50.0,
              :day => DateTime.civil(2007, 9, 6, 12, 0, 0),
              :from => deals(:bankaccount),
              :to => Deal.income,
              :resource => deals(:bankaccount).take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert_equal 6, Balance.open.count, "Wrong open balances count"
    @rubs -= 50.0
    test_balance deals(:bankaccount).balance,
                 @rubs.accounting_norm,
                 @rubs.accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    assert_equal 1, Income.open.count, "Wrong open incomes count"
    @profit -= 50.0
    assert (Income.open.first.value + @profit).accounting_zero?,
      "Wrong income value"

    #Direct monetary gain
    t = Txn.new :fact => Fact.new(
              :amount => 50.0,
              :day => DateTime.civil(2007, 9, 7, 12, 0, 0),
              :from => Deal.income,
              :to => deals(:bankaccount),
              :resource => deals(:bankaccount).give)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert_equal 6, Balance.open.count, "Wrong open balances count"
    @rubs += 50.0
    test_balance deals(:bankaccount).balance,
                 @rubs.accounting_norm,
                 @rubs.accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    assert_equal 0, Income.open.count, "Wrong open incomes count"
    @profit = 0.0
  end

  def direct_gains_losses
    #Receive prepayment from forex deal #4
    t = Txn.new :fact => Fact.new(
              :amount => 400.0 * 34.95,
              :day => DateTime.civil(2007, 9, 10, 12, 0, 0),
              :from => @forex4,
              :to => deals(:bankaccount),
              :resource => @forex4.take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert_equal 7, Balance.open.count, "Wrong open balances count"
    test_balance @forex4.balance,
                 400.0,
                 (400.0 * 34.95).accounting_norm,
                 "active" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    @rubs += 400.0 * 34.95
    test_balance deals(:bankaccount).balance,
                 @rubs.accounting_norm,
                 @rubs.accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    #Direct write-off - loss
    t = Txn.new :fact => Fact.new(
              :amount => 400.0,
              :day => DateTime.civil(2007, 9, 10, 12, 0, 0),
              :from => deals(:bankaccount2),
              :to => Deal.income,
              :resource => deals(:bankaccount2).take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert_equal 7, Balance.open.count, "Wrong open balances count"
    @euros -= 400.0
    test_balance deals(:bankaccount2).balance,
                 @euros.accounting_norm,
                 (@euros * 34.2).accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    assert_equal 1, Income.open.count, "Wrong open incomes count"
    @profit -= 400.0 * 34.2
    assert (@profit + Income.open.first.value), "Wrong income value"

    #Direct write-in - gain
    t = Txn.new :fact => Fact.new(
              :amount => 400.0,
              :day => DateTime.civil(2007, 9, 10, 12, 0, 0),
              :from => Deal.income,
              :to => @forex4,
              :resource => @forex4.give)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert_equal 6, Balance.open.count, "Wrong open balances count"
    #check balances
    test_balance Balance.open[0],
                 100000.0 / 10000.0,
                 100000.0,
                 "active" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    test_balance Balance.open[1],
                 142000.0 / 10000.0,
                 142000.0,
                 "active" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    test_balance Balance.open[2],
                 1.0,
                 70000.0,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    test_balance Balance.open[3],
                 1.0,
                 2000.0,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    test_balance Balance.open[4],
                 @rubs.accounting_norm,
                 @rubs.accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    test_balance Balance.open[5],
                 @euros.accounting_norm,
                 (@euros * 34.2).accounting_norm,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    assert_equal 1, Income.open.count, "Wrong open incomes count"
    @profit += 400.0 * 34.95
    assert (@profit + Income.open.first.value), "Wrong income value"
  end

  def test_txn_list_by_time_frame_and_deal
    txns = deals(:bankaccount).txns(DateTime.civil(2007, 8, 29, 12, 0, 0),
      DateTime.civil(2007, 8, 29, 12, 0, 0))
    assert_equal 2, txns.count, "Deal txns count is wrong"
    txns.each do |item|
      assert item.instance_of?(Txn), "Wrong txn instance"
      assert (deals(:bankaccount) == item.fact.from or
          deals(:bankaccount) == item.fact.to), "Wrong txn value"
    end

    txns = deals(:bankaccount).txns(DateTime.civil(2007, 8, 30, 12, 0, 0),
      DateTime.civil(2007, 8, 30, 12, 0, 0))
    assert_equal 2, txns.count, "Deal txns count is wrong"
    txns.each do |item|
      assert item.instance_of?(Txn), "Wrong txn instance"
      assert (deals(:bankaccount) == item.fact.from or
          deals(:bankaccount) == item.fact.to), "Wrong txn value"
    end

    balances = deals(:bankaccount).
      balance_range(DateTime.civil(2007, 8, 29, 12, 0, 0),
                    DateTime.civil(2007, 8, 29, 12, 0, 0))
    assert_equal 1, balances.count, "Wrong balances count"
    assert_equal DateTime.civil(2007, 8, 29, 12, 0, 0), balances.first.start,
      "Wrong balance start value"
    assert_equal DateTime.civil(2007, 8, 29, 12, 0, 0), balances.first.paid,
      "Wrong balance paid value"
  end

  def test_balance(b, amount, value, side)
    yield(false, b.nil?, "Balance is nil")
    yield(amount, b.amount, "Wrong balance amount")
    yield(value, b.value, "Wrong balance value")
    yield(side, b.side, "Wrong balance side")
  end

  def init_facts
    facts = [
      Fact.new(:amount => 100000.0,
              :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
              :from => deals(:equityshare2),
              :to => deals(:bankaccount),
              :resource => deals(:equityshare2).take),
      Fact.new(:amount => 142000.0,
              :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
              :from => deals(:equityshare1),
              :to => deals(:bankaccount),
              :resource => deals(:equityshare1).take),
      Fact.new(:amount => 70000.0,
              :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
              :from => deals(:bankaccount),
              :to => deals(:purchase),
              :resource => deals(:bankaccount).take),
      Fact.new(:amount => 1000.0,
              :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
              :from => deals(:forex),
              :to => deals(:bankaccount2),
              :resource => deals(:forex).take),
      Fact.new(:amount => 34950.0,
              :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
              :from => deals(:bankaccount),
              :to => deals(:forex),
              :resource => deals(:bankaccount).take),
      Fact.new(:amount => 1000.0,
              :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
              :from => deals(:bankaccount2),
              :to => deals(:forex2),
              :resource => deals(:bankaccount2).take)
    ]
    facts.each do |f|
      assert f.save, "Fact is not saved"
    end
    facts
  end
end
