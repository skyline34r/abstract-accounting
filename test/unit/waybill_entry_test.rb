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
end
