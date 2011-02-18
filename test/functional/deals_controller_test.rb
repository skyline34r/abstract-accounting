require 'test_helper'

class DealsControllerTest < ActionController::TestCase
  test "should get index deal" do
    get :index
    assert_response :success
    assert_not_nil assigns(:deals)
  end

  test "should get new deal" do
    xml_http_request :get, :new
    assert_response :success
  end

end
