require 'test_helper'

class ResourcesControllerTest < ActionController::TestCase
  setup do
    @asset = assets(:iron)
    @money = money(:eur)
  end

  test "should get index resource" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resources)
  end

  test "should get new asset in resource" do
    xml_http_request :get, :new_asset
    assert_response :success
  end

  test "should get new money in resource" do
    xml_http_request :get, :new_money
    assert_response :success
  end

  test "should get edit asset in resource" do
    xml_http_request :get, :edit_asset, :id => @asset.to_param
    assert_response :success
  end

  test "should get edit money in resource" do
    xml_http_request :get, :edit_money, :id => @money.to_param
    assert_response :success
  end

end
