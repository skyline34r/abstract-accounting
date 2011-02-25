require 'test_helper'

class FactsControllerTest < ActionController::TestCase
  test "should get index fact" do
    get :index
    assert_response :success
  end

  test "should create fact" do
    assert_difference('Fact.count') do
       xml_http_request :post, :create,
                        :fact => { :day => DateTime.civil(2008, 02, 04, 0, 0, 0),
                                   :amount => 400,
                                   :from_deal_id => deals(:purchase).id,
                                   :to_deal_id => deals(:metall).id,
                                   :resource_id => assets(:steel).id,
                                   :resource_type => "Asset" }
    end
    assert_equal 1, Fact.where(:amount => 400,
                               :from_deal_id => deals(:purchase).id,
                               :to_deal_id => deals(:metall).id,
                               :resource_id => assets(:steel).id,
                               :resource_type => "Asset").count,
      'Fact not saved'
  end
end
