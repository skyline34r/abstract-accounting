require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "should get index user" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new user" do
    xml_http_request :get, :new
    assert_response :success
  end

end
