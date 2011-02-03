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
  end

  test "loss transaction" do
    init_facts.each do |fact|
      assert Txn.new(:fact => fact).save, "Txn is not saved"
    end

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

    b = deals(:equityshare2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal (100000.0 / deals(:equityshare2).rate).accounting_norm,
      b.amount, "Wrong balance amount"
    assert_equal 100000.0, b.value, "Wrong balance value"
    assert_equal "active", b.side, "Wrong balance side"

    b = deals(:equityshare1).balance
    assert !b.nil?, "Balance is nil"
    assert_equal (142000.0 / deals(:equityshare1).rate).accounting_norm,
      b.amount, "Wrong balance amount"
    assert_equal 142000.0, b.value, "Wrong balance value"
    assert_equal "active", b.side, "Wrong balance side"

    b = deals(:purchase).balance
    assert !b.nil?, "Balance is nil"
    assert_equal (70000.0 * deals(:purchase).rate).accounting_norm,
      b.amount, "Wrong balance amount"
    assert_equal 70000.0, b.value, "Wrong balance value"
    assert_equal "passive", b.side, "Wrong balance side"

    b = deals(:bankaccount).balance
    value = 100000.0 + 142000.0 - 70000.0 +
      (1000.0 * (deals(:forex2).rate - 1 / deals(:forex).rate))
    assert !b.nil?, "Balance is nil"
    assert_equal value.accounting_norm, b.amount, "Wrong balance amount"
    assert_equal value.accounting_norm, b.value, "Wrong balance value"
    assert_equal "passive", b.side, "Wrong balance side"
    #forex deal #3
    forex = Deal.new :tag => "forex deal 3",
      :rate => (1 / 34.2),
      :entity => entities(:sbrfbank),
      :give => money(:rub),
      :take => money(:eur)
    assert forex.save, "Forex deal 3 is not saved"
    #Pay forex deal #3
    t = Txn.new :fact => Fact.new(
              :amount => (5000.0 / forex.rate).accounting_norm,
              :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
              :from => deals(:bankaccount),
              :to => forex,
              :resource => deals(:bankaccount).take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert_equal 5, Balance.open.count, "Open balances count is wrong"
    b = deals(:bankaccount).balance
    value -= (5000.0 / forex.rate).accounting_norm
    assert !b.nil?, "Balance is nil"
    assert_equal value.accounting_norm, b.amount, "Wrong balance amount"
    assert_equal value.accounting_norm, b.value, "Wrong balance value"
    assert_equal "passive", b.side, "Wrong balance side"
    b = forex.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 5000.0, b.amount, "Wrong balance amount"
    assert_equal (5000.0 / forex.rate).accounting_norm, b.value,
      "Wrong balance value"
    assert_equal "passive", b.side, "Wrong balance side"

    #Recieve settlement from forex deal #3
    t = Txn.new :fact => Fact.new(
              :amount => 5000.0,
              :day => DateTime.civil(2007, 9, 4, 12, 0, 0),
              :from => forex,
              :to => deals(:bankaccount2),
              :resource => forex.take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    assert_equal 5, Balance.open.count, "Open balances count is wrong"
    assert forex.balance.nil?, "Balance is not nil"
    b = deals(:bankaccount2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal 5000.0, b.amount, "Wrong balance amount"
    assert_equal (5000.0 / forex.rate).accounting_norm, b.value,
      "Wrong balance value"
    assert_equal "passive", b.side, "Wrong balance side"

    #Create flow for office rent
    landlord = Entity.new :tag => "Audit service"
    assert landlord.save, "Audit service not saved"
    rent = Asset.new :tag => "office space"
    assert rent.save, "Asset not saved"
    office = Deal.new :tag => "rented office 1",
      :rate => (1 / 2000.0),
      :entity => landlord,
      :give => money(:rub),
      :take => rent
    assert office.save, "Flow is not saved"

    #Accrue office rent for august
    t = Txn.new :fact => Fact.new(
              :amount => 1.0,
              :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
              :from => office,
              :to => Deal.income,
              :resource => office.take)
    assert t.fact.valid?, "Fact is not valid"
    assert t.fact.save, "Fact is not saved"

    assert_equal 6, State.open.count, "State count is wrong"
    s = office.state
    assert !s.nil?, "State is nil"
    assert_equal (1 / office.rate).accounting_norm, s.amount,
      "State amount is wrong"
    assert_equal money(:rub), s.resource, "State resource is wrong"

    s = deals(:bankaccount).state
    assert !s.nil?, "State is nil"
    assert_equal value.accounting_norm, s.amount,
      "State amount is wrong"
    assert_equal money(:rub), s.resource, "State resource is wrong"
  end

  private
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
