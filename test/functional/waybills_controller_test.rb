require 'test_helper'

class WaybillsControllerTest < ActionController::TestCase
  setup do
    sign_in_by_user
  end

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
                                      :vatin => '500100732259' },
                        :entry_resource => ['test1'],
                        :entry_amount => ['5'],
                        :entry_unit => ['kg']
    end
    assert_equal 1, Waybill.where(:vatin =>'500100732259').count,
      'Waybill not saved'
  end

  test "should create waybills with text entity" do
    assert_difference('Waybill.count') do
       xml_http_request :post, :create,
                        :waybill => { :date => DateTime.now,
                                      :owner => entities(:sergey),
                                      :vatin => '500100732259' },
                        :organization_text => 'abstract',
                        :entry_resource => ['test1'],
                        :entry_amount => ['5'],
                        :entry_unit => ['kg']
    end
    assert_equal 1, Entity.where(:tag =>'abstract').count,
      'Entity not saved'
    assert_equal 1, Waybill.where(:vatin =>'500100732259').count,
      'Waybill not saved'
  end

  test "should get view waybills" do
    xml_http_request :get, :view
    assert_response :success
    assert_not_nil assigns(:waybills)
  end

  test "should get show waybills entries" do
    xml_http_request :post, :create,
                     :waybill => { :date => DateTime.now,
                                   :owner => entities(:sergey),
                                   :vatin => '500100732259' },
                     :organization_text => 'abstract',
                      :entry_resource => ['test1', 'test2'],
                     :entry_amount => ['5', '8'],
                     :entry_unit => ['kg', 'm']
    xml_http_request :get, :show, :id => 1
    assert_response :success
    assert_not_nil assigns(:entries)
  end

  test "should_get_index_of_waybills" do
    xml_http_request :get, :index
    assert_response :success
  end

end
