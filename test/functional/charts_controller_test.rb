require 'test_helper'

class ChartsControllerTest < ActionController::TestCase
  setup do
    sign_in_by_user
  end

  test "should get index chart" do
    xml_http_request :get, :index
    assert_response :success
  end

  test "should create chart" do
    assert_difference('Chart.count') do
       xml_http_request :post, :create,
                        :chart => { :currency_id => money(:eur).id }
    end
    assert_equal 1, Chart.where(:currency_id => money(:eur).id).count,
      'Chart not saved'
  end
end
