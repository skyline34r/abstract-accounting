require 'test_helper'

class GeneralLedgersControllerTest < ActionController::TestCase
  setup do
    sign_in_by_user
  end

  test "should get index general ledgers" do
    xml_http_request :get, :index
    assert_response :success
  end

  test "should get view general ledgers" do
    xml_http_request :get, :view
    assert_response :success
  end

end
