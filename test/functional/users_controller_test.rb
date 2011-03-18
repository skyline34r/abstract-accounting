require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "should get index user" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new user" do
    xml_http_request :get, :new
    assert_response :success
  end

  test "should get edit user" do
    u = User.new(:email => "user@mail.com",
                 :password => "user_pass",
                 :password_confirmation => "user_pass")
    assert u.save, "User can't be saved"
    xml_http_request :get, :edit, :id => u.id
    assert_response :success
  end

end
