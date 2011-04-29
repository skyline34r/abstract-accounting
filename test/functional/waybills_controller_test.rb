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

  test "should create waybills with text entity" do
    assert_difference('Waybill.count') do
       xml_http_request :post, :create,
                        :waybill => { :date => DateTime.now,
                                      :owner => entities(:sergey),
                                      :vatin => '500100732259',
                                      :organization_text => 'abstract' }
    end
    assert_equal 1, Entity.where(:tag =>'abstract').count,
      'Entity not saved'
    assert_equal 1, Waybill.where(:vatin =>'500100732259').count,
      'Waybill not saved'
  end
end
