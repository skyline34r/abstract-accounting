require 'test_helper'

class TranscriptsControllerTest < ActionController::TestCase
  setup do
    sign_in_by_user
  end

  test "should get index of transcripts" do
    xml_http_request :get, :index
    assert_response :success
  end

  test "should show transcripts" do
    xml_http_request :get, :load, :deal_id => deals(:bankaccount).id,
                                  :start => "09/05/2007",
                                  :stop => "10/06/2011"
    assert_response :success
    assert_not_nil assigns(:transcript)
  end
end
