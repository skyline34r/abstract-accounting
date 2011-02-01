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
    init_facts
    assert !Fact.pendings.nil?, "Pending facts is nil"
    assert_equal 6, Fact.pendings.count, "Pending facts count is not equal to 6"

    #check pending facts
    pendingFact = Fact.pendings.first
    assert_equal 100000.0, pendingFact.amount, "Wrong pending fact amount"
    assert_equal deals(:equityshare2), pendingFact.from,
      "Wrong pending fact from deal"
    assert_equal deals(:bankaccount), pendingFact.to,
      "Wrong pending fact to deal"

    #check currency
    assert_equal 1, Chart.all.count, "Wrong chart count"
    assert_equal money(:rub), Chart.all.first.currency,
      "Wrong chart currency"

    t = Txn.new :fact => pendingFact
    assert t.valid?, "Transaction is not valid"
    assert t.save, "Txn is not saved"

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

    assert_equal 5, Fact.pendings.count, "Pending facts count is not equal to 5"
    #check pending facts
    pendingFact = Fact.pendings.first
    assert_equal 142000.0, pendingFact.amount, "Wrong pending fact amount"
    assert_equal deals(:equityshare1), pendingFact.from,
      "Wrong pending fact from deal"
    assert_equal deals(:bankaccount), pendingFact.to,
      "Wrong pending fact to deal"

    t = Txn.new :fact => pendingFact
    assert t.valid?, "Transaction is not valid"
    assert t.save, "Txn is not saved"

    assert_equal 3, Balance.all.count, "Balance count is not equal to 3"
    b = deals(:equityshare2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare2), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare2).give, b.resource,
      "balance invalid resource"
    assert_equal "active", b.side, "balance invalid side"
    assert_equal 100000.0 / deals(:equityshare2).rate, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0, b.value,
      "balance value is not equal"
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount).take, b.resource,
      "balance invalid resource"
    assert_equal "passive", b.side, "balance invalid side"
    assert_equal 100000.0 + 142000.0, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0 + 142000.0, b.value,
      "balance value is not equal"
    b = deals(:equityshare1).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare1), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare1).give, b.resource,
      "balance invalid resource"
    assert_equal "active", b.side, "balance invalid side"
    assert_equal 142000.0 / deals(:equityshare1).rate, b.amount,
      "balance amount is not equal"
    assert_equal 142000.0, b.value,
      "balance value is not equal"

    assert_equal 4, Fact.pendings.count, "Pending facts count is not equal to 4"
    #check pending facts
    pendingFact = Fact.pendings.first
    assert_equal 70000.0, pendingFact.amount, "Wrong pending fact amount"
    assert_equal deals(:bankaccount), pendingFact.from,
      "Wrong pending fact from deal"
    assert_equal deals(:purchase), pendingFact.to,
      "Wrong pending fact to deal"

    t = Txn.new :fact => pendingFact
    assert t.valid?, "Transaction is not valid"
    assert t.save, "Txn is not saved"

    assert_equal 5, Balance.all.count, "Balance count is not equal to 5"
    b = deals(:equityshare2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare2), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare2).give, b.resource,
      "balance invalid resource"
    assert_equal "active", b.side, "balance invalid side"
    assert_equal 100000.0 / deals(:equityshare2).rate, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0, b.value,
      "balance value is not equal"
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount).take, b.resource,
      "balance invalid resource"
    assert_equal "passive", b.side, "balance invalid side"
    assert_equal 100000.0 + 142000.0 - 70000.0, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0 + 142000.0 - 70000.0, b.value,
      "balance value is not equal"
    b = deals(:equityshare1).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare1), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare1).give, b.resource,
      "balance invalid resource"
    assert_equal "active", b.side, "balance invalid side"
    assert_equal 142000.0 / deals(:equityshare1).rate, b.amount,
      "balance amount is not equal"
    assert_equal 142000.0, b.value,
      "balance value is not equal"
    b = deals(:purchase).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:purchase), b.deal, "balance invalid deal"
    assert_equal deals(:purchase).take, b.resource,
      "balance invalid resource"
    assert_equal "passive", b.side, "balance invalid side"
    assert_equal 1.0, b.amount,
      "balance amount is not equal"
    assert_equal 70000.0, b.value,
      "balance value is not equal"

    assert_equal 3, Fact.pendings.count, "Pending facts count is not equal to 3"
    #check pending facts
    pendingFact = Fact.pendings.first
    assert_equal 1000.0, pendingFact.amount, "Wrong pending fact amount"
    assert_equal deals(:forex), pendingFact.from,
      "Wrong pending fact from deal"
    assert_equal deals(:bankaccount2), pendingFact.to,
      "Wrong pending fact to deal"

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

    t = Txn.new :fact => pendingFact
    assert t.valid?, "Transaction is not valid"
    assert t.save, "Txn is not saved"

    assert_equal 7, Balance.all.count, "Balance count is not equal to 7"
    b = deals(:equityshare2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare2), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare2).give, b.resource,
      "balance invalid resource"
    assert_equal "active", b.side, "balance invalid side"
    assert_equal 100000.0 / deals(:equityshare2).rate, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0, b.value,
      "balance value is not equal"
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount).take, b.resource,
      "balance invalid resource"
    assert_equal "passive", b.side, "balance invalid side"
    assert_equal 100000.0 + 142000.0 - 70000.0, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0 + 142000.0 - 70000.0, b.value,
      "balance value is not equal"
    b = deals(:equityshare1).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare1), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare1).give, b.resource,
      "balance invalid resource"
    assert_equal "active", b.side, "balance invalid side"
    assert_equal 142000.0 / deals(:equityshare1).rate, b.amount,
      "balance amount is not equal"
    assert_equal 142000.0, b.value,
      "balance value is not equal"
    b = deals(:purchase).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:purchase), b.deal, "balance invalid deal"
    assert_equal deals(:purchase).take, b.resource,
      "balance invalid resource"
    assert_equal "passive", b.side, "balance invalid side"
    assert_equal 1.0, b.amount,
      "balance amount is not equal"
    assert_equal 70000.0, b.value,
      "balance value is not equal"
    b = deals(:forex).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:forex), b.deal, "balance invalid deal"
    assert_equal deals(:forex).give, b.resource,
      "balance invalid resource"
    assert_equal "active", b.side, "balance invalid side"
    assert_equal (1000.0 / deals(:forex).rate).accounting_norm, b.amount,
      "balance amount is not equal"
    assert_equal (1000.0 / deals(:forex).rate).accounting_norm, b.value,
      "balance value is not equal"
    b = deals(:bankaccount2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount2), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount2).give, b.resource,
      "balance invalid resource"
    assert_equal "passive", b.side, "balance invalid side"
    assert_equal 1000.0, b.amount,
      "balance amount is not equal"
    assert_equal (1000.0 / deals(:forex).rate).accounting_norm, b.value,
      "balance value is not equal"

    assert_equal 2, Fact.pendings.count, "Pending facts count is not equal to 2"
    #check pending facts
    pendingFact = Fact.pendings.first
    assert_equal 34950.0, pendingFact.amount, "Wrong pending fact amount"
    assert_equal deals(:bankaccount), pendingFact.from,
      "Wrong pending fact from deal"
    assert_equal deals(:forex), pendingFact.to,
      "Wrong pending fact to deal"

    t = Txn.new :fact => pendingFact
    assert t.valid?, "Transaction is not valid"
    assert t.save, "Txn is not saved"

    assert_equal 6, Balance.all.count, "Balance count is not equal to 6"
    b = deals(:equityshare2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare2), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare2).give, b.resource,
      "balance invalid resource"
    assert_equal "active", b.side, "balance invalid side"
    assert_equal 100000.0 / deals(:equityshare2).rate, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0, b.value,
      "balance value is not equal"
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount).take, b.resource,
      "balance invalid resource"
    assert_equal "passive", b.side, "balance invalid side"
    assert_equal 100000.0 + 142000.0 - 70000.0 -
      (1000.0 / deals(:forex).rate).accounting_norm, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0 + 142000.0 - 70000.0 -
      (1000.0 / deals(:forex).rate).accounting_norm, b.value,
      "balance value is not equal"
    b = deals(:equityshare1).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare1), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare1).give, b.resource,
      "balance invalid resource"
    assert_equal "active", b.side, "balance invalid side"
    assert_equal 142000.0 / deals(:equityshare1).rate, b.amount,
      "balance amount is not equal"
    assert_equal 142000.0, b.value,
      "balance value is not equal"
    b = deals(:purchase).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:purchase), b.deal, "balance invalid deal"
    assert_equal deals(:purchase).take, b.resource,
      "balance invalid resource"
    assert_equal "passive", b.side, "balance invalid side"
    assert_equal 1.0, b.amount,
      "balance amount is not equal"
    assert_equal 70000.0, b.value,
      "balance value is not equal"
    b = deals(:forex).balance
    assert b.nil?, "Balance is not nil"
    b = deals(:bankaccount2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount2), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount2).give, b.resource,
      "balance invalid resource"
    assert_equal "passive", b.side, "balance invalid side"
    assert_equal 1000.0, b.amount,
      "balance amount is not equal"
    assert_equal (1000.0 / deals(:forex).rate).accounting_norm, b.value,
      "balance value is not equal"

    assert_equal (1000.0 / deals(:forex).rate).accounting_norm,
      Fact.find(pendingFact.id).txn.value, "Txn value is not equal"

    assert_equal 0, Income.all.count, "Income count is not equal to 0"
  end

  private
  def init_facts
    #fill table
    assert Fact.new(:amount => 100000.0,
      :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
      :from => deals(:equityshare2),
      :to => deals(:bankaccount),
      :resource => deals(:equityshare2).take).save, "Fact is not saved"

    assert Fact.new(:amount => 142000.0,
      :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
      :from => deals(:equityshare1),
      :to => deals(:bankaccount),
      :resource => deals(:equityshare1).take).save, "Fact is not saved"

    assert Fact.new(:amount => 70000.0,
      :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
      :from => deals(:bankaccount),
      :to => deals(:purchase),
      :resource => deals(:bankaccount).take).save, "Fact is not saved"

    assert Fact.new(:amount => 1000.0,
      :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
      :from => deals(:forex),
      :to => deals(:bankaccount2),
      :resource => deals(:forex).take).save, "Fact is not saved"

    assert Fact.new(:amount => 34950.0,
      :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
      :from => deals(:bankaccount),
      :to => deals(:forex),
      :resource => deals(:bankaccount).take).save, "Fact is not saved"

    assert Fact.new(:amount => 1000.0,
      :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
      :from => deals(:bankaccount2),
      :to => deals(:forex2),
      :resource => deals(:bankaccount2).take).save, "Fact is not saved"
  end
end
