require 'test_helper'

class GeneralLedgerControllerTest < ActionController::TestCase

  test "should get index general ledger" do
    get :index
    assert_response :success
    assert_not_nil assigns(:general_ledger)
  end

end
