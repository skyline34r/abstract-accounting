require 'test_helper'

class RuleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "rule must be saved" do
    r = Rule.new :tag => "test rule", :deal => deals(:equityshare1),
      :rate => 1.0, :change_side => true, :fact_side => false,
      :from => deals(:equityshare2), :to => deals(:bankaccount)
    assert r.valid?, "Rule is not valid"
    assert r.save, "Rule is not saved"
  end

  test "rule workflow" do
    #Create resources
    shipment = Asset.new :tag => "shipment"
    assert shipment.save, "Asset is not saved"
    x = Asset.new :tag => "resource x"
    assert x.save, "Asset is not saved"
    y = Asset.new :tag => "resource y"
    assert y.save, "Asset is not saved"
    #Create entities
    keeper = Entity.new :tag => "keeper"
    assert keeper.save, "Entity is not saved"
    bank = Entity.new :tag => "bank"
    assert bank.save, "Entity is not saved"
    supplier = Entity.new :tag => "supplier"
    assert supplier.save, "Entity is not saved"
    buyer = Entity.new :tag => "buyer"
    assert buyer.save, "Entity is not saved"
    #Create deals
    bankAccount = Deal.new :entity => bank, :give => money(:rub),
      :take => money(:rub), :rate => 1.0, :tag => "bank account"
    assert bankAccount.save, "Deal is not saved"
    purchaseX = Deal.new :entity => supplier, :give => money(:rub),
      :take => x, :rate => (1.0 / 100.0), :tag => "purchase 1"
    assert purchaseX.save, "Deal is not saved"
    purchaseY = Deal.new :entity => supplier, :give => money(:rub),
      :take => y, :rate => (1.0 / 150.0), :tag => "purchase 2"
    assert purchaseY.save, "Deal is not saved"
    storageX = Deal.new :entity => keeper, :give => x,
      :take => x, :rate => 1.0, :tag => "storage 1"
    assert storageX.save, "Deal is not saved"
    storageY = Deal.new :entity => keeper, :give => y,
      :take => y, :rate => 1.0, :tag => "storage 2"
    assert storageY.save, "Deal is not saved"
    saleX = Deal.new :entity => supplier, :give => x,
      :take => money(:rub), :rate => 120.0, :tag => "sale 1"
    assert saleX.save, "Deal is not saved"
    saleY = Deal.new :entity => supplier, :give => y,
      :take => money(:rub), :rate => 160.0, :tag => "sale 2"
    assert saleY.save, "Deal is not saved"
    #Register and process preparing transactions
    t = Txn.new(:fact => Fact.new(:amount => 50.0,
              :day => DateTime.civil(2008, 9, 16, 12, 0, 0),
              :from => purchaseX,
              :to => storageX,
              :resource => purchaseX.take))
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"
    t = Txn.new(:fact => Fact.new(:amount => 50.0,
              :day => DateTime.civil(2008, 9, 16, 12, 0, 0),
              :from => purchaseY,
              :to => storageY,
              :resource => purchaseY.take))
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"
    #Test balances before rules
    assert_equal 4, Balance.open.count, "Wrong open balances count"
    b = purchaseX.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 5000.0, b.amount, "Wrong balance amount"
    assert_equal 5000.0, b.value, "Wrong balance value"
    assert_equal "active", b.side, "Wrong balance side"
    b = purchaseY.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 7500.0, b.amount, "Wrong balance amount"
    assert_equal 7500.0, b.value, "Wrong balance value"
    assert_equal "active", b.side, "Wrong balance side"
    b = storageX.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 50.0, b.amount, "Wrong balance amount"
    assert_equal 5000.0, b.value, "Wrong balance value"
    assert_equal "passive", b.side, "Wrong balance side"
    b = storageY.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 50.0, b.amount, "Wrong balance amount"
    assert_equal 7500.0, b.value, "Wrong balance value"
    assert_equal "passive", b.side, "Wrong balance side"
  end
end
