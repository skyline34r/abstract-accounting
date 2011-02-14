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

  test "should create asset in resources" do
    assert_difference('Asset.count') do
       xml_http_request :post, :create_asset, :asset => { :tag => 'Iron tester' }
    end
    assert_equal 1, Asset.where(:tag =>'Iron tester').count,
      'Asset \'Iron tester\' not saved'
  end

  test "should create money in resources" do
    assert_difference('Money.count') do
       xml_http_request :post, :create_money, :money => { :alpha_code => 'BY', :num_code => 123 }
    end
    assert_equal 1, Money.where(:alpha_code => 'BY', :num_code => 123).count,
      'Money \'BY\' not saved'
  end

  test "should update asset in resources" do
    xml_http_request :put, :update_asset, :id => @asset.to_param,
      :asset => { :tag => 'Iron update' }
    assert_response :success
    assert_equal 'Iron update', Asset.find(@asset.id).tag,
      'Asset \'Iron\' not edited'
  end

  test "should update money in resources" do
    xml_http_request :put, :update_money, :id => @money.to_param,
      :money => { :alpha_code => 'BLR', :num_code => 333 }
    assert_response :success
    assert_equal 'BLR', Money.find(@money.id).alpha_code,
      'Money \'EUR\' not edited'
    assert_equal 333, Money.find(@money.id).num_code,
      'Money \'978\' not edited'
  end
end
