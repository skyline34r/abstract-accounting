
require "test_helper"

class StoreHouseTest < ActiveSupport::TestCase
  test "assign entity to storehouse" do
    assert_equal entities(:sergey), StoreHouse.new(entities(:sergey)).entity, "Entity is wrong"
    assert_equal nil, StoreHouse.new(1).entity, "Entity is wrong"
  end

  test "check storehouse contain only storage deals" do
    assert_equal 0, StoreHouse.new(entities(:sergey)).length, "Wrong storehouse length"

    assert Deal.new(:tag => "Test deal for money to asset exchange",
             :entity => entities(:sergey), :give => money(:rub),
             :take => assets(:sonyvaio), :rate => 1.0).save, "Deal is not created"
    assert Deal.new(:tag => "Test deal for money to money exchange",
             :entity => entities(:sergey), :give => money(:rub),
             :take => money(:eur), :rate => 1.0).save, "Deal is not created"
    assert Deal.new(:tag => "Test deal for asset to money exchange",
             :entity => entities(:sergey), :give => assets(:sonyvaio),
             :take => money(:rub), :rate => 1.0).save, "Deal is not created"

    assert_equal 0, StoreHouse.new(entities(:sergey)).length, "Wrong storehouse length"

    assert Waybill.new(:date => DateTime.civil(2011, 5, 3, 12, 0, 0),
      :owner => entities(:sergey), :organization => Entity.new(:tag => "Some organization"),
      :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
        :unit => "th", :amount => 10), WaybillEntry.new(:resource => Asset.new(:tag => "underlayer"),
        :unit => "m", :amount => 600)]).save, "Waybill is not saved"

    sh = StoreHouse.new(entities(:sergey))
    assert_equal 2, sh.length, "StoreHouse entries is not equal to 2"
    sh.each do |item|
      assert item.instance_of?(StoreHouseEntry), "Wrong storehouse entry type"
      if item.resource == assets(:sonyvaio)
        assert_equal 10, item.amount, "Wrong storehouse entry amount"
      elsif item.resource == Asset.find_by_tag("underlayer")
        assert_equal 600, item.amount, "Wrong storehouse entry amount"
      else
        assert false, "Unknown storehouse entry resource"
      end
    end
  end
end
