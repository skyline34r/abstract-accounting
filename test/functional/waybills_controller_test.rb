require 'test_helper'

class WaybillsControllerTest < ActionController::TestCase

  test "should get new waybills" do
    xml_http_request :get, :new
    assert_response :success
  end

end
