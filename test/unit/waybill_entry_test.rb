require 'test_helper'

class WaybillEntryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "all data must present" do
    assert WaybillEntry.new(:resource => assets(:sonyvaio),
      :waybill => Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract)),
      :unit => "th", :amount => 10).valid?, "Valid waybill entry"
    assert WaybillEntry.new(
      :waybill => Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract)),
      :unit => "th", :amount => 10).invalid?, "Invalid waybill entry"
    assert WaybillEntry.new(:resource => assets(:sonyvaio),
      :unit => "th", :amount => 10).invalid?, "Invalid waybill entry"
    assert WaybillEntry.new(:resource => assets(:sonyvaio),
      :waybill => Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract)),
      :amount => 10).invalid?, "Invalid waybill entry"
    assert WaybillEntry.new(:resource => assets(:sonyvaio),
      :waybill => Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract)),
      :unit => "th").invalid?, "Invalid waybill entry"
  end

  test "relations between waybill and waybill_entries" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract))
    assert wb.save, "Save waybill with entries"
    wb.waybill_entries.create(:resource => assets(:sonyvaio),
      :unit => "th", :amount => 10)
    wb.waybill_entries.create(:resource => Asset.new(:tag => "wire"),
      :unit => "m", :amount => 25)
    assert_equal 2, WaybillEntry.all.length, "Waybill entries count is equal to 2"
    assert WaybillEntry.new(:waybill => wb, :resource => Asset.new(:tag => "edger"),
      :unit => "th", :amount => 20).save, "Save waybill entry"
    assert_equal 3, WaybillEntry.all.length, "Waybill entries count is equal to 3"
  end

  test "assign text for resource" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract))
    assert wb.save, "Save waybill with entries"

    we = WaybillEntry.new(:waybill => wb, :unit => "th", :amount => 20)
    we.assign_resource_text("edge")
    assert we.save, "Save waybill entry"
    assert_equal 1, Asset.where(:tag => "edge").length, "Check asset is created"

    we = WaybillEntry.new(:waybill => wb, :unit => "th", :amount => 10)
    we.assign_resource_text("sonyvaio")
    assert we.save, "Save waybill entry"
    assert_equal 1, Asset.where(:tag => "sonyvaio").length, "Check asset is not created"
  end

  test "case insensitive comparison" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                  :organization => entities(:abstract))
    assert wb.save, "Save waybill with entries"

    we = WaybillEntry.new(:waybill => wb, :unit => "th", :amount => 20)
    we.assign_resource_text("edge")
    assert we.save, "Save waybill entry"
    assert_equal 1, Asset.where(:tag => "edge").length, "Check asset is created"

    we = WaybillEntry.new(:waybill => wb, :unit => "th", :amount => 10)
    we.assign_resource_text("eDgE")
    assert we.save, "Save waybill entry"
    assert_equal 1, Asset.where(:tag => "edge").length, "Check asset is created"
    assert_equal 0, Asset.where(:tag => "eDgE").length, "Check asset is not created"
  end
end
