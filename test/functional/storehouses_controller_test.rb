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
    xml_http_request :get, :new, :filter => "waybill"
    assert_response :success
  end

  test "should_create_release_storehouse" do
    wb = Waybill.new(:document_id => "12345",
                     :created => DateTime.now, :owner => entities(:sergey),
                     :from => entities(:abstract),
                     :place => places(:orsha))
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    assert wb.save, "Can't save waybill with entries"
    assert_difference('StorehouseRelease.count') do
       xml_http_request :post, :create,
                        :date => DateTime.now,
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
    wb = Waybill.new(:document_id => "12345",
                     :created => DateTime.civil(2011, 5, 16, 12, 0, 0),
                     :owner => entities(:sergey),
                     :from => entities(:abstract),
                     :place => places(:orsha))
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    assert wb.save, "Can't save waybill with entries"
    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 5, 16, 12, 0, 0),
      :owner => entities(:sergey), :place => places(:orsha),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(Product.find_by_resource_id(assets(:sonyvaio)), 3)
    assert sr.save, "StorehouseRelease not saved"
    xml_http_request :get, :show, :id => sr.id
    assert_response :success
    assert_not_nil assigns(:owner)
    assert_not_nil assigns(:date)
    assert_not_nil assigns(:to)
  end

  test "should_get_view_release" do
    wb = Waybill.new(:document_id => "12345",
                     :created => DateTime.civil(2011, 5, 16, 12, 0, 0),
                     :owner => entities(:sergey),
                     :from => entities(:abstract),
                     :place => places(:orsha))
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    assert wb.save, "Can't save waybill with entries"
    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 5, 16, 12, 0, 0),
      :owner => entities(:sergey), :place => places(:orsha),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(Product.find_by_resource_id(assets(:sonyvaio)), 3)
    assert sr.save, "StorehouseRelease not saved"
    xml_http_request :get, :view_release, :id => sr.id
    assert_response :success
    assert_not_nil assigns(:resources)
  end

  test "should_cancel_release" do
    wb = Waybill.new(:document_id => "12345",
                     :created => DateTime.civil(2011, 5, 16, 12, 0, 0),
                     :owner => entities(:sergey),
                     :from => entities(:abstract),
                     :place => places(:orsha))
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    assert wb.save, "Can't save waybill with entries"
    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 5, 16, 12, 0, 0),
      :owner => entities(:sergey), :place => places(:orsha),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(Product.find_by_resource_id(assets(:sonyvaio)), 3)
    assert sr.save, "StorehouseRelease not saved"
    xml_http_request :post, :cancel, :id => sr.id
    assert_response :success
  end

  test "should_apply_release" do
    wb = Waybill.new(:document_id => "12345",
                     :created => DateTime.civil(2011, 5, 16, 12, 0, 0),
                     :owner => entities(:sergey),
                     :from => entities(:abstract),
                     :place => places(:orsha))
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    assert wb.save, "Can't save waybill with entries"
    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 5, 16, 12, 0, 0),
      :owner => entities(:sergey), :place => places(:orsha),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(Product.find_by_resource_id(assets(:sonyvaio)), 3)
    assert sr.save, "StorehouseRelease not saved"
    xml_http_request :post, :apply, :id => sr.id
    assert_response :success
  end

  test "should_get_list_of_waybills" do
    xml_http_request :get, :waybill_list
    assert_response :success
    assert_not_nil assigns(:waybills)
  end

  test "should_get_list_of_waybills_entries" do
    wb = Waybill.new(:document_id => "123456",
                     :created => DateTime.now, :owner => entities(:sergey),
                     :from => entities(:abstract),
                     :place => Place.find_by_tag("Access to storehouse"),
                     :vatin => '500100732259')
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    assert wb.save, "Can't save waybill with entries"
    xml_http_request :get, :waybill_entries_list, :id => wb.id
    assert_response :success
    assert_not_nil assigns(:entries)
  end

  test "should_get_new_release_of_storehouse_by_resource" do
    xml_http_request :get, :new, :filter => "resource"
    assert_response :success
  end

  test "should_get_return_of_storehouse" do
    xml_http_request :get, :return
    assert_response :success
  end

  test "should_get_return_list" do
    xml_http_request :get, :return_list
    assert_response :success
    assert_not_nil assigns(:storehouse)
  end

  test "should_return_resource" do
    p = Place.find_by_tag "Access to storehouse"
    e = Entity.new :tag => "Entity 2"
    assert e.save, "Entity is not saved"
    u = User.new(:email => "test2@mail.com",
                 :password => "test2_pass",
                 :password_confirmation => "test2_pass",
                 :entity_id => e.id,
                 :role_ids => [roles(:operator).id])
    u.place = p
    assert u.save, "User can't be saved"

    wb = Waybill.new :owner => e, :document_id => "12834", :place => p,
      :from => "Organization Store", :created => DateTime.civil(2011, 4, 2, 12, 0, 0)
    wb.add_resource assets(:sonyvaio).tag, "th", 100
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new :created => DateTime.civil(2011, 4, 3, 12, 0, 0),
      :owner => e, :place => p, :to => entities(:sergey)
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 30
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "Storehouse release is not applied"

    assert_difference('StorehouseReturn.count') do
       xml_http_request :post, :return_resources,
                        :resource_id => [assets(:sonyvaio).id],
                        :return_amount => [3]
    end

    assert_equal 1, StorehouseReturn.all.count, "StorehouseReturn count is not equal to 1"

  end

end
