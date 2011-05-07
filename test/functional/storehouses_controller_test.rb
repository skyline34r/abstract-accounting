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
    xml_http_request :get, :release
    assert_response :success
  end

  test "should_create_release_storehouse" do
    assert_difference('StorehouseRelease.count') do
       xml_http_request :post, :create_release,
                        :to => 'TestTo',
                        :resource_id => ['5'],
                        :release_amount => ['3']
    end
    assert_equal 1, assigns(:release).resources.length,
      "Resources count is not equal to 1"
  end
end
