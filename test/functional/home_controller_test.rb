require 'test_helper'

class BalancesControllerTest < ActionController::TestCase
 def should_get_home_index
    get :index
    assert_response :success
 end

 def should_get_home_main
    xml_http_request :get, :main
    assert_response :success
  end
end
