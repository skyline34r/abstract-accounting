require 'test_helper'

class DealsControllerTest < ActionController::TestCase
  setup do
    sign_in_by_user
  end

  test "should get index deal" do
    xml_http_request :get, :index
    assert_response :success
  end

  test "should get new deal" do
    xml_http_request :get, :new
    assert_response :success
  end

  test "should create deal" do
    assert_difference('Deal.count') do
       xml_http_request :post, :create,
                        :deal => { :tag => 'purchase tester',
                                   :rate => 30,
                                   :entity_id => entities(:sergey).id,
                                   :give_id => money(:rub).id,
                                   :give_type => "Money",
                                   :take_id => assets(:aasiishare).id,
                                   :take_type => "Asset",
                                   :isOffBalance => false }
    end
    assert_equal 1, Deal.where(:tag =>'purchase tester').count,
      'Deal \'purchase tester\' not saved'
  end

  test "should get view deal" do
    xml_http_request :get, :view
    assert_response :success
    assert_not_nil assigns(:deals)
  end

  test "should create deal with rules" do
    assert_difference('Deal.count') do
       xml_http_request :post, :create,
                        :deal => { :tag => 'purchase tester',
                                   :rate => 30,
                                   :entity_id => entities(:sergey).id,
                                   :give_id => money(:rub).id,
                                   :give_type => "Money",
                                   :take_id => assets(:aasiishare).id,
                                   :take_type => "Asset",
                                   :isOffBalance => false },
                        :rules => [{ :tag => 'deal rule 1',
                                     :from_id => deals(:equityshare1).id,
                                     :to_id => deals(:equityshare2).id,
                                     :fact_side => false,
                                     :change_side => true,
                                     :rate => 55.0 },
                                   { :tag => 'deal rule 2',
                                     :from_id => deals(:bankaccount).id,
                                     :to_id => deals(:equityshare1).id,
                                     :fact_side => false,
                                     :change_side => true,
                                     :rate => 15.0 }]
    end
    assert_equal 1, Deal.where(:tag =>'purchase tester').count,
      'Deal \'purchase tester\' not saved'
    assert_equal 2, Rule.all.count, "Rules can't be set"
  end
end
