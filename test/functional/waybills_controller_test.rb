require 'test_helper'

class WaybillsControllerTest < ActionController::TestCase

  test "should get new waybills" do
    xml_http_request :get, :new
    assert_response :success
  end

  test "should create waybills" do
    assert_difference('Waybill.count') do
       xml_http_request :post, :create,
                        :waybill => { :date => DateTime.now,
                                      :owner => entities(:sergey),
                                      :organization => entities(:abstract),
                                      :vatin => '500100732259' }
    end
    assert_equal 1, Waybill.where(:vatin =>'500100732259').count,
      'Waybill not saved'
  end
end
