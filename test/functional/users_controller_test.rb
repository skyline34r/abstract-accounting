require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "should get index user" do
    get :index
    assert_response :success
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

  test "should create user" do
    assert_difference('User.count') do
       xml_http_request :post, :create,
                        :user => { :email => "user@mail.com",
                                   :password => "user_pass",
                                   :password_confirmation => "user_pass"}
    end
    assert_equal 1, User.where(:email =>'user@mail.com').count,
      'User not saved'
  end

  test "should update user" do
    u = User.new(:email => "user@mail.com",
                 :password => "user_pass",
                 :password_confirmation => "user_pass")
    assert u.save, "User can't be saved"

    xml_http_request :put, :update, :id => u.id,
      :user => { :email => "change@mail.com"}
    assert_response :success
    assert_equal 'change@mail.com', User.find(u.id).email,
      'User not edited'
  end

  test "should create user with role" do
    assert_difference('User.count') do
       xml_http_request :post, :create,
                        :user => { :email => "user@mail.com",
                                   :password => "user_pass",
                                   :password_confirmation => "user_pass",
                                   :role_ids => [ roles(:user).id, roles(:operator).id]
                                 }
    end
    assert_equal 1, User.where(:email =>'user@mail.com').count,
      "User not saved"
    assert_equal 2, User.where(:email =>'user@mail.com').first.roles.count,
      "Roles can't be setup"
  end

  test "should get view user" do
    xml_http_request :get, :view
    assert_response :success
    assert_not_nil assigns(:users)
  end
end
