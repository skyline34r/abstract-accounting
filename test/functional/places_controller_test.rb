require 'test_helper'

class PlacesControllerTest < ActionController::TestCase
  setup do
    sign_in_by_user
  end

  test "should get index place" do
    xml_http_request :get, :index
    assert_response :success
  end

  test "should get new place" do
    xml_http_request :get, :new
    assert_response :success
  end

  test "should get edit place" do
    xml_http_request :get, :edit, :id => places(:orsha).id
    assert_response :success
  end

  test "should create place" do
    assert_difference('Place.count') do
       xml_http_request :post, :create, :place => { :tag => 'Vitebsk' }
    end
    assert_equal 1, Place.where(:tag =>'Vitebsk').count,
      'Place \'Vitebsk\' not saved'
  end

  test "should update place" do
    xml_http_request :put, :update, :id => places(:orsha).id,
      :place => { :tag => 'Vitebsk' }
    assert_response :success
    assert_equal 'Vitebsk', Place.find(places(:orsha).id).tag,
      'Place \'Vitebsk\' not edited'
  end

  test "should get view place" do
    xml_http_request :get, :view
    assert_response :success
    assert_not_nil assigns(:places)
  end

end
