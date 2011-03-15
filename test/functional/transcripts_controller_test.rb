require 'test_helper'

class TranscriptsControllerTest < ActionController::TestCase
  test "should get index of transcripts" do
    get :index
    assert_response :success
  end
end
