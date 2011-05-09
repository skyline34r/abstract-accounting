require 'test_helper'

class PlacesControllerTest < ActionController::TestCase

  test "should get index place" do
    xml_http_request :get, :index
    assert_response :success
  end

  test "should get new place" do
    xml_http_request :get, :new
    assert_response :success
  end

  test "should get edit place" do
    xml_http_request :get, :edit, :id => places(:minsk).id
    assert_response :success
  end

end
