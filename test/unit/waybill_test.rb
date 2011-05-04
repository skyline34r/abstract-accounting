require 'test_helper'

class WaybillTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "validate waybill" do
    assert Waybill.new.invalid?, "Empty waybill is valid"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
                      :organization => entities(:abstract),
                      :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                        :unit => "th", :amount => 10)]).valid?,
                      "Wrong waybill without vatin"
  end

  test "validate VATIN" do
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract), :vatin => "1234",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)]).invalid?,
              "Waybill short vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "1234567890123",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)]).invalid?,
              "Waybill long vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "7830002293",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)]).valid?,
              "Waybill valid vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "7830002295",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)]).invalid?,
              "Waybill invalid vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "500100732259",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)]).valid?,
              "Waybill valid vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "500100732269",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)]).invalid?,
              "Waybill invalid vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "500100732253",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)]).invalid?,
              "Waybill invalid vatin number"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "1234d678901a",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)]).invalid?,
              "Waybill invalid vatin number"
  end

  test "VATIN must be unique" do
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :vatin => "500100732259",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)]).save,
              "Waybill not saved"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:abstract),
              :organization => entities(:sergey),
              :vatin => "500100732259",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)]).invalid?,
              "Waybill vatin is not unique"
  end
  test "save waybill with organization text" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :vatin => "7830002293",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)])
    wb.assign_organization_text("abstract")
    assert wb.save, "Waybill not saved"


    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :vatin => "7930002297",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)])
    wb.assign_organization_text("abstract1")
    assert wb.save, "Waybill not saved"
    assert_equal 1,Entity.where(:tag => "abstract1").length, "Abstract1 entity is not saved"
  end

  test "save two bills without vatin" do
    assert Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :organization => entities(:abstract),
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)]).save, "Save first waybill"
    assert Waybill.new(:date => DateTime.now, :owner => entities(:jdow),
              :organization => entities(:abstract),
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)]).save, "Save first waybill"
  end

  test "save case insensitive" do
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :vatin => "7930002297",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)])
    wb.assign_organization_text("abstract1")
    assert wb.save, "Waybill not saved"
    assert_equal 1,Entity.where(:tag => "abstract1").length, "Abstract1 entity is not saved"
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :vatin => "7830002293",
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)])
    wb.assign_organization_text("AbsTract1")
    assert wb.save, "Waybill not saved"
    assert_equal 1,Entity.where(:tag => "abstract1").length, "Abstract1 entity is not saved"
    assert_equal 0,Entity.where(:tag => "AbsTract1").length, "AbsTract1 entity saved"
  end

  test "save deals after save waybill" do
    deals_count = Deal.all.count

    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)])
    wb.assign_organization_text("abstract1")
    assert wb.save, "Waybill not saved"

    deals_count += 2
    assert_equal deals_count, Deal.all.count, "Deals is not created"
    assert_equal 1, Deal.find_all_by_give_and_take_and_entity(assets(:sonyvaio), assets(:sonyvaio), entities(:sergey)).count, "Owner deals is not created"
    assert_equal 1, Deal.find_all_by_give_and_take_and_entity(assets(:sonyvaio), assets(:sonyvaio), wb.organization).count, "Owner deals is not created"

    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 5)])
    wb.assign_organization_text("abstract1")

    assert wb.save, "Waybill not saved"
    assert_equal deals_count, Deal.all.count, "Deals is not created"
    assert_equal 1, Deal.find_all_by_give_and_take_and_entity(assets(:sonyvaio), assets(:sonyvaio), entities(:sergey)).count, "Owner deals is not created"
    assert_equal 1, Deal.find_all_by_give_and_take_and_entity(assets(:sonyvaio), assets(:sonyvaio), wb.organization).count, "Owner deals is not created"
  end

  test "save storehouse deals for every entry in waybill" do

    deals_count = Deal.all.count

    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 10)])
    wb.assign_organization_text("abstract1")
    assert wb.save, "Waybill not saved"

    deals_count += 2
    assert_equal deals_count, Deal.all.count, "Deals is not created"
    assert_equal 1, Deal.find_all_by_give_and_take_and_entity(assets(:sonyvaio), assets(:sonyvaio), entities(:sergey)).count, "Owner deals is not created"
    assert_equal 1, Deal.find_all_by_give_and_take_and_entity(assets(:sonyvaio), assets(:sonyvaio), wb.organization).count, "Owner deals is not created"

    rf = Asset.new(:tag => "roofing felt")
    wb = Waybill.new(:date => DateTime.now, :owner => entities(:sergey),
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
                :unit => "th", :amount => 5),WaybillEntry.new(:resource => rf,
                :unit => "m", :amount => 250)])
    wb.assign_organization_text("abstract1")
    assert wb.save, "Waybill not saved"

    deals_count += 2
    assert_equal deals_count, Deal.all.count, "Deals is not created"
    assert_equal 1, Deal.find_all_by_give_and_take_and_entity(assets(:sonyvaio), assets(:sonyvaio), entities(:sergey)).count, "Owner deals is not created"
    assert_equal 1, Deal.find_all_by_give_and_take_and_entity(assets(:sonyvaio), assets(:sonyvaio), wb.organization).count, "Owner deals is not created"
    assert_equal 1, Deal.find_all_by_give_and_take_and_entity(rf, rf, entities(:sergey)).count, "Owner deals is not created"
    assert_equal 1, Deal.find_all_by_give_and_take_and_entity(rf, rf, wb.organization).count, "Owner deals is not created"
  end
end
