require 'test_helper'

class RolesControllerTest < ActionController::TestCase

  test "should get index of roles" do
    get :index
    assert_response :success
    assert_not_nil assigns(:roles)
  end

  test "should get new role" do
    xml_http_request :get, :new
    assert_response :success
  end
  
  test "should create role" do
    assert_difference('Role.count') do
       xml_http_request :post, :create, :role => { :name => "admin" }
    end
    assert_equal 1, Role.where(:name =>'admin').count,
      'Role not saved'
  end
  
end
