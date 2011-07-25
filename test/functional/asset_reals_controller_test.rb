require 'test_helper'

class AssetRealsControllerTest < ActionController::TestCase
  setup do
    @asset = asset_reals(:abstractasi)
    sign_in_by_user
  end

  test "should get index" do
    xml_http_request :get, :index
    assert_response :success
  end

  test "should get new" do
    xml_http_request :get, :new
    assert_response :success
  end

  test "should get edit" do
    xml_http_request :get, :edit, :id => @asset.to_param
    assert_response :success
  end

  test "should get create" do
    assert_difference('AssetReal.count') do
       xml_http_request :post, :create, :asset_real => { :tag => 'abstract thing' }
    end
    assert_not_nil AssetReal.find_by_tag('abstract thing'),
      "AssetReal 'abstract thing' not saved"
  end

  test "should get update" do
    xml_http_request :put, :update, :id => @asset.to_param,
      :asset_real => { :tag => 'Abstract ASI share 2' }
    assert_response :success
    assert_not_nil AssetReal.find_by_tag('Abstract ASI share 2'),
      "AssetReal 'Abstract ASI share' not edited"
  end

  test "should get view" do
    xml_http_request :get, :view
    assert_response :success
    assert_not_nil assigns(:asset_reals)
  end

end
