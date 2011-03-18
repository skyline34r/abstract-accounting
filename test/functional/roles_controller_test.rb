require 'test_helper'

class RolesControllerTest < ActionController::TestCase
  test "should get index of roles" do
    get :index
    assert_response :success
    assert_not_nil assigns(:roles)
  end
end
