require 'test_helper'

class ResourcesControllerTest < ActionController::TestCase

  test "should get index resource" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resources)
  end

end
