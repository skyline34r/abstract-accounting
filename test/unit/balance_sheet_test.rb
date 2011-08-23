require "test_helper"

class BalanceSheetTest < ActiveSupport::TestCase
  test "check balance sheet loaded for only facts" do
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

    bs = BalanceSheet.find(:day => DateTime.now)
    assert_equal 0, bs.balances.length, "Wrong balances count"

    t = Txn.new(:fact => Fact.new(:amount => 310.0,
              :day => DateTime.civil(2011, 6, 6, 12, 0, 0),
              :from => exchange,
              :to => keep,
              :resource => exchange.take))
    assert t.fact.save, "Fact is not saved"

    bs = BalanceSheet.find(:day => DateTime.now)
    assert_equal 2, bs.balances.length, "Wrong balances count"
    check_balance bs.balances[0],
                 10.0,
                 0.0,
                 "active" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    check_balance bs.balances[1],
                 310.0,
                 0.0,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end

    assert t.save, "Txn is not saved"

    bs = BalanceSheet.find(:day => DateTime.now)
    assert_equal 2, bs.balances.length, "Wrong balances count"
    check_balance bs.balances[0],
                 10.0,
                 310.0,
                 "active" do |expected, value, msg|
      assert_equal expected, value, msg
    end
    check_balance bs.balances[1],
                 310.0,
                 310.0,
                 "passive" do |expected, value, msg|
      assert_equal expected, value, msg
    end
  end

  test "check balance sheet filtering" do
    f = Fact.new(:amount => 100000.0,
                :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
                :from => deals(:equityshare2),
                :to => deals(:bankaccount),
                :resource => deals(:equityshare2).take)
    assert f.save, "Fact is not saved"
    assert Txn.new(:fact => f).save, "Txn is not saved"
    f = Fact.new(:amount => 142000.0,
                :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
                :from => deals(:equityshare1),
                :to => deals(:bankaccount),
                :resource => deals(:equityshare1).take)
    assert f.save, "Fact is not saved"
    assert Txn.new(:fact => f).save, "Txn is not saved"
    f = Fact.new(:amount => 70000.0,
                :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => deals(:purchase),
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    assert Txn.new(:fact => f).save, "Txn is not saved"
    f = Fact.new(:amount => 1000.0,
                :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
                :from => deals(:forex),
                :to => deals(:bankaccount2),
                :resource => deals(:forex).take)
    assert f.save, "Fact is not saved"
    assert Txn.new(:fact => f).save, "Txn is not saved"
    f = Fact.new(:amount => 34950.0,
                :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => deals(:forex),
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    assert Txn.new(:fact => f).save, "Txn is not saved"
    f = Fact.new(:amount => 1000.0,
                :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => deals(:forex2),
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    assert Txn.new(:fact => f).save, "Txn is not saved"
    f = Fact.new(:amount => 1000.0 * deals(:forex2).rate,
                :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
                :from => deals(:forex2),
                :to => deals(:bankaccount),
                :resource => deals(:forex2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    forex = Deal.new :tag => "forex deal 3",
      :rate => (1 / 34.2),
      :entity => entities(:sbrfbank),
      :give => money(:rub),
      :take => money(:eur)
    assert forex.save, "Forex deal 3 is not saved"
    f = Fact.new(:amount => (5000.0 / forex.rate).accounting_norm,
                :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => forex,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 5000.0,
                :day => DateTime.civil(2007, 9, 4, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount2),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
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
    f = Fact.new(:amount => 1.0,
                :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
                :from => office,
                :to => Deal.income,
                :resource => office.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    forex = Deal.new :tag => "forex deal 4",
      :rate => 34.95,
      :entity => entities(:sbrfbank),
      :give => money(:eur),
      :take => money(:rub)
    assert forex.save, "Flow is not saved"
    f = Fact.new(:amount => 2000.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => forex,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => (2500.0 * 34.95),
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 600.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => forex,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 100.0 * 34.95,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 2 * 2000.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => office,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 50.0,
                :day => DateTime.civil(2007, 9, 6, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => Deal.income,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 50.0,
                :day => DateTime.civil(2007, 9, 7, 12, 0, 0),
                :from => Deal.income,
                :to => deals(:bankaccount),
                :resource => deals(:bankaccount).give)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 400.0 * 34.95,
                :day => DateTime.civil(2007, 9, 10, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 400.0,
                :day => DateTime.civil(2007, 9, 10, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => Deal.income,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 400.0,
                :day => DateTime.civil(2007, 9, 10, 12, 0, 0),
                :from => Deal.income,
                :to => forex,
                :resource => forex.give)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    b = BalanceSheet.find(:order => { 'deal.tag' => 'asc' }).balances
    assert_equal deals(:bankaccount).id, b[0].deal_id, "Wrong deal sorting"
    assert_equal deals(:bankaccount2).id, b[1].deal_id, "Wrong deal sorting"
    assert_equal deals(:equityshare1).id, b[2].deal_id, "Wrong deal sorting"
    assert_equal deals(:equityshare2).id, b[3].deal_id, "Wrong deal sorting"
    assert_equal deals(:purchase).id, b[4].deal_id, "Wrong deal sorting"
    assert_equal office.id, b[5].deal_id, "Wrong deal sorting"
    assert_equal "Income", b[6].class.name, "Wrong deal sorting"

    b = BalanceSheet.find(:order => { 'deal.tag' => 'desc' }).balances
    assert_equal "Income", b[0].class.name, "Wrong deal sorting"
    assert_equal office.id, b[1].deal_id, "Wrong deal sorting"
    assert_equal deals(:purchase).id, b[2].deal_id, "Wrong deal sorting"
    assert_equal deals(:equityshare2).id, b[3].deal_id, "Wrong deal sorting"
    assert_equal deals(:equityshare1).id, b[4].deal_id, "Wrong deal sorting"
    assert_equal deals(:bankaccount2).id, b[5].deal_id, "Wrong deal sorting"
    assert_equal deals(:bankaccount).id, b[6].deal_id, "Wrong deal sorting"

    b = BalanceSheet.find(:order => { 'entity.tag' => 'asc' }).balances
    assert_equal "Income", b[0].class.name, "Wrong entity sorting"
    assert_equal office.id, b[1].deal_id, "Wrong entity sorting"
    assert_equal deals(:purchase).id, b[2].deal_id, "Wrong entity sorting"
    assert_equal deals(:equityshare2).id, b[3].deal_id, "Wrong entity sorting"
    assert_equal deals(:bankaccount).id, b[4].deal_id, "Wrong entity sorting"
    assert_equal deals(:bankaccount2).id, b[5].deal_id, "Wrong entity sorting"
    assert_equal deals(:equityshare1).id, b[6].deal_id, "Wrong entity sorting"

    sbrfbank = entities(:sbrfbank)
    sbrfbank.real = entity_reals(:aa)
    assert sbrfbank.save, "Entity is not saved"

    b = BalanceSheet.find(:order => { 'entity.tag' => 'desc' }).balances
    assert_equal deals(:equityshare1).id, b[0].deal_id, "Wrong entity sorting"
    assert_equal deals(:equityshare2).id, b[1].deal_id, "Wrong entity sorting"
    assert_equal deals(:purchase).id, b[2].deal_id, "Wrong entity sorting"
    assert_equal office.id, b[3].deal_id, "Wrong entity sorting"
    assert_equal deals(:bankaccount).id, b[4].deal_id, "Wrong entity sorting"
    assert_equal deals(:bankaccount2).id, b[5].deal_id, "Wrong entity sorting"
    assert_equal "Income", b[6].class.name, "Wrong entity sorting"


    b = BalanceSheet.find(:order => { 'resource.tag' => 'asc' }).balances
    assert_equal "Income", b[0].class.name, "Wrong resource sorting"
    assert_equal deals(:equityshare2).id, b[1].deal_id, "Wrong resource sorting"
    assert_equal deals(:equityshare1).id, b[2].deal_id, "Wrong resource sorting"
    assert_equal deals(:bankaccount2).id, b[3].deal_id, "Wrong resource sorting"
    assert_equal deals(:purchase).id, b[4].deal_id, "Wrong resource sorting"
    assert_equal office.id, b[5].deal_id, "Wrong resource sorting"
    assert_equal deals(:bankaccount).id, b[6].deal_id, "Wrong resource sorting"

    aasiishare = assets(:aasiishare)
    aasiishare.real = asset_reals(:notebooksv)
    assert aasiishare.save, "Asset is not saved"

    b = BalanceSheet.find(:order => { 'resource.tag' => 'desc' }).balances
    assert_equal deals(:purchase).id, b[0].deal_id, "Wrong resource sorting"
    assert_equal office.id, b[1].deal_id, "Wrong resource sorting"
    assert_equal deals(:bankaccount).id, b[2].deal_id, "Wrong resource sorting"
    assert_equal deals(:equityshare2).id, b[3].deal_id, "Wrong resource sorting"
    assert_equal deals(:equityshare1).id, b[4].deal_id, "Wrong resource sorting"
    assert_equal deals(:bankaccount2).id, b[5].deal_id, "Wrong resource sorting"
    assert_equal "Income", b[6].class.name, "Wrong resource sorting"

    b = BalanceSheet.find(:order => { 'physical.debit' => 'asc' }).balances
    assert_equal deals(:equityshare2).id, b[0].deal_id, "Wrong physical debit sorting"
    assert_equal deals(:equityshare1).id, b[1].deal_id, "Wrong physical debit sorting"
    assert_equal "Income", b[2].class.name, "Wrong physical debit sorting"
    assert_equal deals(:purchase).id, b[3].deal_id, "Wrong physical debit sorting"
    assert_equal office.id, b[4].deal_id, "Wrong physical debit sorting"
    assert_equal deals(:bankaccount2).id, b[5].deal_id, "Wrong physical debit sorting"
    assert_equal deals(:bankaccount).id, b[6].deal_id, "Wrong physical debit sorting"

    b = BalanceSheet.find(:order => { 'accounting.debit' => 'asc' }).balances
    assert_equal deals(:equityshare2).id, b[0].deal_id, "Wrong accounting debit sorting"
    assert_equal deals(:equityshare1).id, b[1].deal_id, "Wrong accounting debit sorting"
    assert_equal "Income", b[2].class.name, "Wrong accounting debit sorting"
    assert_equal office.id, b[3].deal_id, "Wrong accounting debit sorting"
    assert_equal deals(:bankaccount2).id, b[4].deal_id, "Wrong accounting debit sorting"
    assert_equal deals(:purchase).id, b[5].deal_id, "Wrong accounting debit sorting"
    assert_equal deals(:bankaccount).id, b[6].deal_id, "Wrong accounting debit sorting"

    b = BalanceSheet.find(:order => { 'physical.credit' => 'asc' }).balances
    assert_equal "Income", b[0].class.name, "Wrong physical credit sorting"
    assert_equal deals(:purchase).id, b[1].deal_id, "Wrong physical credit sorting"
    assert_equal office.id, b[2].deal_id, "Wrong physical credit sorting"
    assert_equal deals(:bankaccount).id, b[3].deal_id, "Wrong physical credit sorting"
    assert_equal deals(:bankaccount2).id, b[4].deal_id, "Wrong physical credit sorting"
    assert_equal deals(:equityshare2).id, b[5].deal_id, "Wrong physical credit sorting"
    assert_equal deals(:equityshare1).id, b[6].deal_id, "Wrong physical credit sorting"

    b = BalanceSheet.find(:order => { 'accounting.credit' => 'asc' }).balances
    assert_equal deals(:purchase).id, b[0].deal_id, "Wrong accounting credit sorting"
    assert_equal office.id, b[1].deal_id, "Wrong accounting credit sorting"
    assert_equal deals(:bankaccount).id, b[2].deal_id, "Wrong accounting credit sorting"
    assert_equal deals(:bankaccount2).id, b[3].deal_id, "Wrong accounting credit sorting"
    assert_equal "Income", b[4].class.name, "Wrong accounting credit sorting"
    assert_equal deals(:equityshare2).id, b[5].deal_id, "Wrong accounting credit sorting"
    assert_equal deals(:equityshare1).id, b[6].deal_id, "Wrong accounting credit sorting"
  end

  def check_balance b, amount, value, side
    yield(false, b.nil?, "Balance is nil")
    yield(amount, b.amount, "Wrong balance amount")
    yield(value, b.value, "Wrong balance value")
    yield(side, b.side, "Wrong balance side")
  end
end