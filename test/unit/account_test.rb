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
