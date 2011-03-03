require 'test_helper'

class QuotesControllerTest < ActionController::TestCase
  test "should get index quote" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotes)
  end

  test "should get new quote" do
    xml_http_request :get, :new
    assert_response :success
  end

end
