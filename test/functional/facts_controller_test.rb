require 'test_helper'

class FactsControllerTest < ActionController::TestCase
  setup do
    sign_in_by_user
  end

  test "should get index fact" do
    xml_http_request :get, :index
    assert_response :success
  end

  test "should create fact" do
    assert_difference('Fact.count') do
       xml_http_request :post, :create,
                        :fact => { :day => DateTime.civil(2008, 02, 04, 0, 0, 0),
                                   :amount => 400.0,
                                   :from_deal_id => deals(:equityshare1).id,
                                   :to_deal_id => deals(:bankaccount).id,
                                   :resource_id => money(:rub).id,
                                   :resource_type => "Money" }
    end
    fact = Fact.where(:amount => 400.0,
                      :from_deal_id => deals(:equityshare1).id,
                      :to_deal_id => deals(:bankaccount).id,
                      :resource_id => money(:rub).id,
                      :resource_type => "Money")
    assert_equal 1, fact.count, 'Fact not saved'
    assert_equal 1, Txn.where(:fact_id => fact.first.id).count,
      'Txn not saved'
  end

  test "should destroy fact" do
    xml_http_request :post, :create,
                     :fact => { :day => DateTime.civil(2008, 02, 04, 0, 0, 0),
                                :amount => 400.0,
                                :from_deal_id => deals(:equityshare1).id,
                                :to_deal_id => deals(:bankaccount).id,
                                :resource_id => money(:rub).id,
                                :resource_type => "Money" }
    fact_id = Fact.where(:amount => 400.0,
                         :from_deal_id => deals(:equityshare1).id,
                         :to_deal_id => deals(:bankaccount).id,
                         :resource_id => money(:rub).id,
                         :resource_type => "Money").first.id
    xml_http_request :delete, :destroy, :id => fact_id
    assert_equal 0, Txn.where(:fact_id => fact_id).count, 'Txn not destroy'
    assert_equal 0, Fact.where(:id => fact_id).count, 'Fact not destroy'
  end
end
