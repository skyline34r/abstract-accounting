require 'test_helper'

class ResourcesControllerTest < ActionController::TestCase

  test "should get index resource" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resources)
  end

  test "should get new asset in resource" do
    xml_http_request :get, :new_asset
    assert_response :success
  end

  test "should get new money in resource" do
    xml_http_request :get, :new_money
    assert_response :success
  end

end
