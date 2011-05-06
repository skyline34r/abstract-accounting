require 'test_helper'

class StorehousesControllerTest < ActionController::TestCase

  test "should_get_index_of_storehouse" do
    xml_http_request :get, :index
    assert_response :success
  end

  test "should_view_storehouse" do
    xml_http_request :get, :view, :entity_id => entities(:sergey).id
    assert_response :success
    assert_not_nil assigns(:storehouse)
  end

  test "should_get_realise_of_storehouse" do
    xml_http_request :get, :realise
    assert_response :success
  end
end
