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
                        :waybill => { :document_id => "123456",
                                      :created => DateTime.now,
                                      :from => entities(:abstract),
                                      :place => places(:orsha),
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
                        :waybill => { :document_id => "123456",
                                      :created => DateTime.now,
                                      :vatin => '500100732259',
                                      :from => 'abstract' },
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
    wb = Waybill.new(:document_id => "123456",
                     :created => DateTime.now, :owner => entities(:sergey),
                     :from => entities(:abstract),
                     :place => places(:orsha),
                     :vatin => '500100732259')
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    assert wb.save, "Can't save waybill with entries"
    xml_http_request :get, :show, :id => wb.id
    assert_response :success
    assert_not_nil assigns(:entries)
  end

  test "should_get_index_of_waybills" do
    xml_http_request :get, :index
    assert_response :success
  end

  test "should get edit" do
    wb = Waybill.new(:document_id => "123456",
                     :created => DateTime.now, :owner => entities(:sergey),
                     :from => entities(:abstract),
                     :place => places(:orsha),
                     :vatin => '500100732259')
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    assert wb.save, "Can't save waybill with entries"
    xml_http_request :get, :edit, :id => wb.to_param
    assert_response :success
  end

  test "should destroy waybill" do
    wb = Waybill.new(:document_id => "123456",
                     :created => DateTime.now, :owner => entities(:sergey),
                     :from => entities(:abstract),
                     :place => places(:orsha),
                     :vatin => '500100732259')
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    assert wb.save, "Can't save waybill with entries"
    assert_difference 'Waybill.disabled.count' do
      xml_http_request :put, :disable, :id => wb.to_param,
                       :waybill => { :comment => "dublicate waybill" }
    end
    assert_equal wb.id, Waybill.disabled.first.id, "Wrong disabled waybill"
  end

end
