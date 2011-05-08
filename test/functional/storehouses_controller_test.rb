require 'test_helper'

class StorehousesControllerTest < ActionController::TestCase
  setup do
    sign_in_by_user
  end

  test "should_get_index_of_storehouse" do
    xml_http_request :get, :index
    assert_response :success
  end

  test "should_view_storehouse" do
    xml_http_request :get, :view, :entity_id => entities(:sergey).id
    assert_response :success
    assert_not_nil assigns(:storehouse)
  end

  test "should_get_release_of_storehouse" do
    xml_http_request :get, :new
    assert_response :success
  end

  test "should_create_release_storehouse" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract))
    wb.waybill_entries << WaybillEntry.new(:resource => assets(:sonyvaio),
      :unit => "th", :amount => 10)
    assert wb.save, "Save waybill with entries"
    assert_difference('StorehouseRelease.count') do
       xml_http_request :post, :create,
                        :to => 'TestTo',
                        :resource_id => [assets(:sonyvaio).id],
                        :release_amount => [3]
    end
    assert_equal 1, assigns(:release).resources.length,
      "Resources count is not equal to 1"
  end

  test "should_get_releases_of_storehouse" do
    xml_http_request :get, :releases
    assert_response :success
  end

  test "should_get_list_of_releases" do
    xml_http_request :get, :list
    assert_response :success
    assert_not_nil assigns(:releases)
  end

  test "should_show_release" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract))
    wb.waybill_entries << WaybillEntry.new(:resource => assets(:sonyvaio),
      :unit => "th", :amount => 10)
    assert wb.save, "Save waybill with entries"
    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 4, 12, 0, 0),
      :owner => entities(:sergey), :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 3)
    assert sr.save, "StorehouseRelease not saved"
    xml_http_request :get, :show, :id => sr.id
    assert_response :success
    assert_not_nil assigns(:owner)
    assert_not_nil assigns(:date)
    assert_not_nil assigns(:to)
  end

  test "should_get_view_release" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract))
    wb.waybill_entries << WaybillEntry.new(:resource => assets(:sonyvaio),
      :unit => "th", :amount => 10)
    assert wb.save, "Save waybill with entries"
    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 4, 12, 0, 0),
      :owner => entities(:sergey), :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 3)
    assert sr.save, "StorehouseRelease not saved"
    xml_http_request :get, :view_release, :id => sr.id
    assert_response :success
    assert_not_nil assigns(:resources)
  end

  test "should_cancel_release" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract))
    wb.waybill_entries << WaybillEntry.new(:resource => assets(:sonyvaio),
      :unit => "th", :amount => 10)
    assert wb.save, "Save waybill with entries"
    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 4, 12, 0, 0),
      :owner => entities(:sergey), :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 3)
    assert sr.save, "StorehouseRelease not saved"
    xml_http_request :post, :cancel, :id => sr.id
    assert_response :success
  end
end
