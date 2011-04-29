require 'test_helper'

class WaybillTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "validate waybill" do
    assert Waybill.new.invalid?, "Empty waybill is valid"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                      :organization => entities(:abstract)).valid?,
                      "Wrong waybill without vatin"
  end

  test "validate VATIN" do
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract), :vatin => "1234").invalid?,
              "Waybill short vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "1234567890123").invalid?,
              "Waybill long vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "7830002293").valid?,
              "Waybill valid vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "7830002295").invalid?,
              "Waybill invalid vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "500100732259").valid?,
              "Waybill valid vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "500100732269").invalid?,
              "Waybill invalid vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "500100732253").invalid?,
              "Waybill invalid vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "1234d678901a").invalid?,
              "Waybill invalid vatin number"
  end

  test "VATIN must be unique" do
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "500100732259").save,
              "Waybill not saved"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:abstract),
              :organization => entities(:sergey),
              :vatin => "500100732259").invalid?,
              "Waybill vatin is not unique"
  end
  test "save waybill with organization text" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :vatin => "7830002293")
    wb.assign_organization_text("abstract")
    if wb.invalid?
      pp wb.errors
    end
    assert wb.save, "Waybill not saved"


    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :vatin => "7930002297")
    wb.assign_organization_text("abstract1")
    assert wb.save, "Waybill not saved"
    assert_equal 1,Entity.where(:tag => "abstract1").length, "Abstract1 entity is not saved"
  end

  test "save two bills without vatin" do
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract)).save, "Save first waybill"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:jdow),
              :organization => entities(:abstract)).save, "Save first waybill"
  end
end
