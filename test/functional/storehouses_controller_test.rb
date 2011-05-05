require 'test_helper'

class StorehousesControllerTest < ActionController::TestCase

  test "should_get_index_of_storehouse" do
    xml_http_request :get, :index
    assert_response :success
  end

end
