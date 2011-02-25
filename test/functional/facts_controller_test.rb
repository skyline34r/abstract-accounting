require 'test_helper'

class FactsControllerTest < ActionController::TestCase
  test "should get index fact" do
    get :index
    assert_response :success
  end

end
