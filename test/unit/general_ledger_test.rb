require "test_helper"

class GeneralLedgerTest < ActiveSupport::TestCase
  test "check general ledger without saved txns" do
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

    gl = GeneralLedger.find
    assert_equal 0, gl.length, "Wrong transcript count"

    t = Txn.new(:fact => Fact.new(:amount => 310.0,
              :day => DateTime.civil(2011, 6, 6, 12, 0, 0),
              :from => exchange,
              :to => keep,
              :resource => exchange.take))
    assert t.fact.save, "Fact is not saved"

    gl = GeneralLedger.find
    assert_equal 1, gl.length, "Wrong transcript count"
    assert_equal t.fact.id, gl[0].fact.id, "Wrong fact"
    assert_equal 0.0, gl[0].value, "Wrong txn value"
    assert_equal 0.0, gl[0].earnings, "Wrong txn earnings"

    assert t.save, "Txn is not saved"

    gl = GeneralLedger.find
    assert_equal 1, gl.length, "Wrong transcript count"
    assert_equal t.fact.id, gl[0].fact.id, "Wrong fact"
    assert_equal 310.0, gl[0].value, "Wrong txn value"
    assert_equal 0.0, gl[0].earnings, "Wrong txn earnings"
  end

  test "check general ledger filtering" do
    f1 = Fact.new(:amount => 100000.0,
                 :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
                 :from => deals(:equityshare2),
                 :to => deals(:bankaccount),
                 :resource => deals(:equityshare2).take)
    assert f1.save, "Fact is not saved"
    assert Txn.new(:fact => f1).save, "Txn is not saved"
    f2 = Fact.new(:amount => 142000.0,
                 :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
                 :from => deals(:equityshare1),
                 :to => deals(:bankaccount),
                 :resource => deals(:equityshare1).take)
    assert f2.save, "Fact is not saved"
    assert Txn.new(:fact => f2).save, "Txn is not saved"
    f3 = Fact.new(:amount => 70000.0,
                 :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
                 :from => deals(:bankaccount),
                 :to => deals(:purchase),
                 :resource => deals(:bankaccount).take)
    assert f3.save, "Fact is not saved"
    assert Txn.new(:fact => f3).save, "Txn is not saved"
    f4 = Fact.new(:amount => 1000.0,
                 :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
                 :from => deals(:forex),
                 :to => deals(:bankaccount2),
                 :resource => deals(:forex).take)
    assert f4.save, "Fact is not saved"
    assert Txn.new(:fact => f4).save, "Txn is not saved"
    f5 = Fact.new(:amount => 34950.0,
                 :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
                 :from => deals(:bankaccount),
                 :to => deals(:forex),
                 :resource => deals(:bankaccount).take)
    assert f5.save, "Fact is not saved"
    assert Txn.new(:fact => f5).save, "Txn is not saved"
    f6 = Fact.new(:amount => 1000.0,
                 :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
                 :from => deals(:bankaccount2),
                 :to => deals(:forex2),
                 :resource => deals(:bankaccount2).take)
    assert f6.save, "Fact is not saved"
    assert Txn.new(:fact => f6).save, "Txn is not saved"

    assert_equal 6, GeneralLedger.find.length, "Wrong transcript count"

    gl = GeneralLedger.find(:order => { 'fact.day' => 'asc' })
    assert_equal f1.id, gl[0].fact_id, "Wrong day sorting"
    assert_equal f2.id, gl[1].fact_id, "Wrong day sorting"
    assert_equal f3.id, gl[2].fact_id, "Wrong day sorting"
    assert_equal f4.id, gl[3].fact_id, "Wrong day sorting"
    assert_equal f5.id, gl[4].fact_id, "Wrong day sorting"
    assert_equal f6.id, gl[5].fact_id, "Wrong day sorting"

    gl = GeneralLedger.find(:order => { 'fact.day' => 'desc' })
    assert_equal f6.id, gl[0].fact_id, "Wrong day sorting"
    assert_equal f3.id, gl[1].fact_id, "Wrong day sorting"
    assert_equal f4.id, gl[2].fact_id, "Wrong day sorting"
    assert_equal f5.id, gl[3].fact_id, "Wrong day sorting"
    assert_equal f1.id, gl[4].fact_id, "Wrong day sorting"
    assert_equal f2.id, gl[5].fact_id, "Wrong day sorting"

    gl = GeneralLedger.find(:order => { 'resource.tag' => 'asc' })
    assert_equal f4.id, gl[0].fact_id, "Wrong resource sorting"
    assert_equal f6.id, gl[1].fact_id, "Wrong resource sorting"
    assert_equal f1.id, gl[2].fact_id, "Wrong resource sorting"
    assert_equal f2.id, gl[3].fact_id, "Wrong resource sorting"
    assert_equal f3.id, gl[4].fact_id, "Wrong resource sorting"
    assert_equal f5.id, gl[5].fact_id, "Wrong resource sorting"

    gl = GeneralLedger.find(:order => { 'resource.tag' => 'desc' })
    assert_equal f1.id, gl[0].fact_id, "Wrong resource sorting"
    assert_equal f2.id, gl[1].fact_id, "Wrong resource sorting"
    assert_equal f3.id, gl[2].fact_id, "Wrong resource sorting"
    assert_equal f5.id, gl[3].fact_id, "Wrong resource sorting"
    assert_equal f4.id, gl[4].fact_id, "Wrong resource sorting"
    assert_equal f6.id, gl[5].fact_id, "Wrong resource sorting"

    gl = GeneralLedger.find(:order => { 'fact.amount' => 'asc' })
    assert_equal f4.id, gl[0].fact_id, "Wrong amount sorting"
    assert_equal f6.id, gl[1].fact_id, "Wrong amount sorting"
    assert_equal f5.id, gl[2].fact_id, "Wrong amount sorting"
    assert_equal f3.id, gl[3].fact_id, "Wrong amount sorting"
    assert_equal f1.id, gl[4].fact_id, "Wrong amount sorting"
    assert_equal f2.id, gl[5].fact_id, "Wrong amount sorting"

    gl = GeneralLedger.find(:order => { 'fact.amount' => 'desc' })
    assert_equal f2.id, gl[0].fact_id, "Wrong amount sorting"
    assert_equal f1.id, gl[1].fact_id, "Wrong amount sorting"
    assert_equal f3.id, gl[2].fact_id, "Wrong amount sorting"
    assert_equal f5.id, gl[3].fact_id, "Wrong amount sorting"
    assert_equal f4.id, gl[4].fact_id, "Wrong amount sorting"
    assert_equal f6.id, gl[5].fact_id, "Wrong amount sorting"

    gl = GeneralLedger.find(:order => { 'debit' => 'asc' })
    assert_equal f4.id, gl[0].fact_id, "Wrong debit sorting"
    assert_equal f5.id, gl[1].fact_id, "Wrong debit sorting"
    assert_equal f6.id, gl[2].fact_id, "Wrong debit sorting"
    assert_equal f3.id, gl[3].fact_id, "Wrong debit sorting"
    assert_equal f1.id, gl[4].fact_id, "Wrong debit sorting"
    assert_equal f2.id, gl[5].fact_id, "Wrong debit sorting"

    gl = GeneralLedger.find(:order => { 'debit' => 'desc' })
    assert_equal f2.id, gl[0].fact_id, "Wrong debit sorting"
    assert_equal f1.id, gl[1].fact_id, "Wrong debit sorting"
    assert_equal f3.id, gl[2].fact_id, "Wrong debit sorting"
    assert_equal f6.id, gl[3].fact_id, "Wrong debit sorting"
    assert_equal f4.id, gl[4].fact_id, "Wrong debit sorting"
    assert_equal f5.id, gl[5].fact_id, "Wrong debit sorting"

    gl = GeneralLedger.find(:order => { 'credit' => 'asc' })
    assert_equal f4.id, gl[0].fact_id, "Wrong credit sorting"
    assert_equal f5.id, gl[1].fact_id, "Wrong credit sorting"
    assert_equal f6.id, gl[2].fact_id, "Wrong credit sorting"
    assert_equal f3.id, gl[3].fact_id, "Wrong credit sorting"
    assert_equal f1.id, gl[4].fact_id, "Wrong credit sorting"
    assert_equal f2.id, gl[5].fact_id, "Wrong credit sorting"

    gl = GeneralLedger.find(:order => { 'credit' => 'desc' })
    assert_equal f2.id, gl[0].fact_id, "Wrong credit sorting"
    assert_equal f1.id, gl[1].fact_id, "Wrong credit sorting"
    assert_equal f3.id, gl[2].fact_id, "Wrong credit sorting"
    assert_equal f4.id, gl[3].fact_id, "Wrong credit sorting"
    assert_equal f5.id, gl[4].fact_id, "Wrong credit sorting"
    assert_equal f6.id, gl[5].fact_id, "Wrong credit sorting"

    gl = GeneralLedger.find(:where => {'fact.day' => {:like => "30"}})
    assert_equal 3, gl.length, "Wrong general ledger length"
    assert_equal f3.id, gl[0].fact_id, "Wrong general ledger filtering"
    assert_equal f4.id, gl[1].fact_id, "Wrong general ledger filtering"
    assert_equal f5.id, gl[2].fact_id, "Wrong general ledger filtering"

    gl = GeneralLedger.find(:where => {'resource.tag' => {:like => "e"}})
    assert_equal 2, gl.length, "Wrong general ledger length"
    assert_equal f4.id, gl[0].fact_id, "Wrong general ledger filtering"
    assert_equal f6.id, gl[1].fact_id, "Wrong general ledger filtering"
  end
end
