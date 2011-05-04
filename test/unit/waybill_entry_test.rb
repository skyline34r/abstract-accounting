require 'test_helper'

class WaybillEntryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "all data must present" do
    assert WaybillEntry.new(:resource => assets(:sonyvaio),
      :unit => "th", :amount => 10).valid?, "Valid waybill entry"
    assert WaybillEntry.new(:unit => "th", :amount => 10).invalid?,
      "Invalid waybill entry"
    assert WaybillEntry.new(:resource => assets(:sonyvaio),
      :amount => 10).invalid?, "Invalid waybill entry"
    assert WaybillEntry.new(:resource => assets(:sonyvaio),
      :unit => "th").invalid?, "Invalid waybill entry"
  end

  test "relations between waybill and waybill_entries" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract))
    wb.waybill_entries << WaybillEntry.new(:resource => assets(:sonyvaio),
      :unit => "th", :amount => 10)
    wb.waybill_entries << WaybillEntry.new(:resource => Asset.new(:tag => "wire"),
      :unit => "m", :amount => 25)
    assert wb.save, "Save waybill with entries"
    assert_equal 2, WaybillEntry.all.length, "Waybill entries count is equal to 2"
    assert WaybillEntry.new(:waybill => wb, :resource => Asset.new(:tag => "edger"),
      :unit => "th", :amount => 20).save, "Save waybill entry"
    assert_equal 3, WaybillEntry.all.length, "Waybill entries count is equal to 3"
  end

  test "assign text for resource" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract))
    we = WaybillEntry.new(:unit => "th", :amount => 20)
    we.assign_resource_text("edge")
    wb.waybill_entries << we
    assert wb.save, "Save waybill with entries"
    assert_equal 1, Asset.where(:tag => "edge").length, "Check asset is created"

    we = WaybillEntry.new(:waybill => wb, :unit => "th", :amount => 10)
    we.assign_resource_text("sonyvaio")
    assert we.save, "Save waybill entry"
    assert_equal 1, Asset.where(:tag => "sonyvaio").length, "Check asset is not created"
  end

  test "case insensitive comparison" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract))

    we = WaybillEntry.new(:unit => "th", :amount => 20)
    we.assign_resource_text("edge")
    wb.waybill_entries << we
    assert wb.save, "Save waybill with entries"
    assert_equal 1, Asset.where(:tag => "edge").length, "Check asset is created"

    we = WaybillEntry.new(:waybill => wb, :unit => "th", :amount => 10)
    we.assign_resource_text("eDgE")
    assert we.save, "Save waybill entry"
    assert_equal 1, Asset.where(:tag => "edge").length, "Check asset is created"
    assert_equal 0, Asset.where(:tag => "eDgE").length, "Check asset is not created"
  end

  test "create or get deal" do
    we = WaybillEntry.new(:unit => "th", :amount => 20)
    we.assign_resource_text("edge")

    d = we.storehouse_deal(entities(:sergey))
    assert_equal nil, d, "Deal is not nil for ntry with new resource"
    assert we.resource.save, "Save resource in waybill entry"

    d = we.storehouse_deal(entities(:sergey))
    assert !d.nil?, "Deal is nil"
    assert d.id.nil?, "Deal is new object"
    assert d.valid?, "Deal is valid object"
    assert_equal entities(:sergey), d.entity, "Deal entity is wrong"
    assert_equal we.resource, d.give, "Deal give is wrong"
    assert_equal we.resource, d.take, "Deal take is wrong"
    assert_equal 1.0, d.rate, "Deal rate is wrong"
    assert_equal "storehouse entity: " + entities(:sergey).tag + "; resource: " + we.resource.tag + ";", d.tag, "Deal tag is wrong"
    assert d.save, "Deal is not saved"

    we = WaybillEntry.new(:unit => "th", :amount => 10)
    we.assign_resource_text("edge")

    d = we.storehouse_deal(entities(:sergey))
    assert !d.nil?, "Deal is nil"
    assert !d.id.nil?, "Deal is not new object"
    assert_equal entities(:sergey), d.entity, "Deal entity is wrong"
    assert_equal we.resource, d.give, "Deal give is wrong"
    assert_equal we.resource, d.take, "Deal take is wrong"
    assert_equal 1.0, d.rate, "Deal rate is wrong"
    assert_equal "storehouse entity: " + entities(:sergey).tag + "; resource: " + we.resource.tag + ";", d.tag, "Deal tag is wrong"
  end
end
