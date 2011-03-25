require 'test_helper'

class QuotesControllerTest < ActionController::TestCase
  setup do
    sign_in_by_user
  end
  
  test "should get index quote" do
    get :index
    assert_response :success
  end

  test "should get new quote" do
    xml_http_request :get, :new
    assert_response :success
  end

  test "should create quote" do
    assert_difference('Quote.count') do
       xml_http_request :post, :create,
                        :quote => { :money_id => money(:rub).id,
                                    :day => DateTime.civil(2010, 02, 04, 0, 0, 0),
                                    :rate => 10 }
    end
    assert_equal 1, Quote.where(:money_id => money(:rub).id).count,
      'Quote not saved'
  end

  test "should get view quote" do
    xml_http_request :get, :view
    assert_response :success
    assert_not_nil assigns(:quotes)
  end
end
