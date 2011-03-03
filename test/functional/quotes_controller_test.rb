require 'test_helper'

class QuotesControllerTest < ActionController::TestCase
  test "should get index quote" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotes)
  end

end
