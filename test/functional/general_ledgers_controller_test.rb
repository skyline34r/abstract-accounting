require 'test_helper'

class GeneralLedgersControllerTest < ActionController::TestCase

  test "should get index general ledgers" do
    get :index
    assert_response :success
    assert_not_nil assigns(:general_ledgers)
  end

end
