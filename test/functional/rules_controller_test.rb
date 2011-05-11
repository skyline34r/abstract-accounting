require 'test_helper'

class RulesControllerTest < ActionController::TestCase

  test "should get index of rules" do
    xml_http_request :get, :index
    assert_response :success
  end

  test "should get view of rules" do
    xml_http_request :get, :view
    assert_response :success
  end

  test "should get data of rules" do
    shipment = Asset.new :tag => "shipment"
    assert shipment.save, "Asset is not saved"
    supplier = Entity.new :tag => "supplier"
    assert supplier.save, "Entity is not saved"
    x = Asset.new :tag => "resource x"
    assert x.save, "Asset is not saved"
    shipmentDeal = Deal.new :tag => "shipment 1", :rate => 1.0,
      :entity => supplier, :give => shipment, :take => shipment,
      :isOffBalance => true
    assert shipmentDeal.save, "Deal is not saved"
    assert_equal true, Deal.find(shipmentDeal.id).isOffBalance,
      "Wrong saved value for is off balance"
    storageX = Deal.new :entity => supplier, :give => x,
      :take => x, :rate => 1.0, :tag => "storage 1"
    assert storageX.save, "Deal is not saved"
    saleX = Deal.new :entity => supplier, :give => x,
      :take => money(:rub), :rate => 120.0, :tag => "sale 1"
    assert saleX.save, "Deal is not saved"
    shipmentDeal.rules.create :tag => "shipment1.rule1",
      :from => storageX, :to => saleX, :fact_side => false,
      :change_side => true, :rate => 27.0

    xml_http_request :get, :data, :deal_id => shipmentDeal.id
    assert_response :success
    assert_not_nil assigns(:rules)
  end

end
