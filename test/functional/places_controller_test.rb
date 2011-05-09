require 'test_helper'

class PlacesControllerTest < ActionController::TestCase

  test "should get index place" do
    xml_http_request :get, :index
    assert_response :success
  end

end
