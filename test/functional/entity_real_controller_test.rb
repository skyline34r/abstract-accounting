require 'test_helper'

class EntityRealControllerTest < ActionController::TestCase
  setup do
    @entity = entity_reals(:aa)
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
    xml_http_request :get, :edit, :id => @entity.to_param
    assert_response :success
  end

  test "should get create" do
    assert_difference('EntityReal.count') do
       xml_http_request :post, :create, :entity_real => { :tag => 'abstract factory' }
    end
    assert_not_nil EntityReal.find_by_tag('abstract factory'),
      "EntityReal 'abstract factory' not saved"
  end

  test "should get update" do
    xml_http_request :put, :update, :id => @entity.to_param,
      :entity_real => { :tag => 'abstract accounting 2' }
    assert_response :success
    assert_not_nil EntityReal.find_by_tag('abstract accounting 2'),
      "Entity 'abstract accounting' not edited"
  end

  test "should get view" do
    xml_http_request :get, :view
    assert_response :success
    assert_not_nil assigns(:entity_reals)
  end

end
