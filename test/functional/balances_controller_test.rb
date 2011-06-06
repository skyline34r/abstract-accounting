require 'test_helper'

class BalancesControllerTest < ActionController::TestCase
  setup do
    sign_in_by_user
  end

  test "should get balance" do
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

    should_get_index_of_balance
    should_load_balance
  end

  def should_get_index_of_balance
    xml_http_request :get, :index
    assert_response :success
  end

  def should_load_balance
    xml_http_request :get, :load, :date => "09/05/2007"
    assert_response :success
    assert_not_nil assigns(:balances)
  end

  def should_get_total_balance
    xml_http_request :get, :total
    assert_response :success
  end
end
