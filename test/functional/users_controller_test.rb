require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "should get index user" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

end
