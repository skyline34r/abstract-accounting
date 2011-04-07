require 'test_helper'

class RulesControllerTest < ActionController::TestCase

  test "should get index of rules" do
    xml_http_request :get, :index
    assert_response :success
  end

end
