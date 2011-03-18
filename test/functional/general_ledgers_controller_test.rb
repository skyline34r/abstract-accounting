require 'test_helper'

class GeneralLedgersControllerTest < ActionController::TestCase
  setup do
    sign_in_by_user
  end

  test "should get index general ledgers" do
    get :index
    assert_response :success
    assert_not_nil assigns(:general_ledgers)
  end

end
