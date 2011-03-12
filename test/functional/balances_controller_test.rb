require 'test_helper'

class BalancesControllerTest < ActionController::TestCase
  test "should get index of balance" do
    t = Txn.new :fact => Fact.new(
              :amount => 100000.0,
              :day => DateTime.civil(2007, 8, 27, 12, 0, 0),
              :from => deals(:equityshare2),
              :to => deals(:bankaccount),
              :resource => deals(:equityshare2).take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    deal = Deal.new :tag => "forex deal 4",
      :rate => 34.95,
      :entity => entities(:sbrfbank),
      :give => money(:eur),
      :take => money(:rub)
    assert deal.save, "Flow is not saved"

    t = Txn.new :fact => Fact.new(
              :amount => 100.0 * 34.95,
              :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
              :from => deal,
              :to => deals(:bankaccount),
              :resource => deal.take)
    assert t.fact.save, "Fact is not saved"
    assert t.save, "Txn is not saved"

    get :index
    assert_response :success
    assert_not_nil assigns(:balances)
  end
end
