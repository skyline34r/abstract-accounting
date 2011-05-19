
require "test_helper"

class StorehouseTest < ActiveSupport::TestCase
  test "assign entity to storehouse" do
    assert_equal entities(:sergey), Storehouse.new(entities(:sergey)).entity, "Entity is wrong"
    assert_equal nil, Storehouse.new.entity, "Entity is wrong"
    assert_equal places(:orsha), Storehouse.new(entities(:sergey), places(:orsha)).place, "Place is wrong"
    assert_equal nil, Storehouse.new.place, "Place is wrong"
  end

  test "check storehouse contain only storage deals" do
    assert_equal 0, Storehouse.new.length, "Wrong storehouse length"

    assert Deal.new(:tag => "Test deal for money to asset exchange",
             :entity => entities(:sergey), :give => money(:rub),
             :take => assets(:sonyvaio), :rate => 1.0).save, "Deal is not created"
    assert Deal.new(:tag => "Test deal for money to money exchange",
             :entity => entities(:sergey), :give => money(:rub),
             :take => money(:eur), :rate => 1.0).save, "Deal is not created"
    assert Deal.new(:tag => "Test deal for asset to money exchange",
             :entity => entities(:sergey), :give => assets(:sonyvaio),
             :take => money(:rub), :rate => 1.0).save, "Deal is not created"

    assert_equal 0, Storehouse.new.length, "Wrong storehouse length"

    assert Place.new(:tag => "Some test place").save, "Entity not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    wb.add_resource "underlayer", "m", 600
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.new
    assert_equal 2, sh.length, "Storehouse entries is not equal to 2"
    sh.each do |item|
      assert item.instance_of?(StorehouseEntry), "Wrong storehouse entry type"
      assert_equal Place.find_by_tag("Some test place"), item.place, "Wrong place"
      if item.product == Product.find_by_resource_id(assets(:sonyvaio))
        assert_equal 10, item.amount, "Wrong storehouse entry amount"
      elsif item.product == Product.find_by_resource_tag("underlayer")
        assert_equal 600, item.amount, "Wrong storehouse entry amount"
      else
        assert false, "Unknown storehouse entry resource"
      end
    end
  end

  test "storehouse do not show deals with empty state" do
    assert Place.new(:tag => "Some test place").save, "Entity not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    wb.add_resource "underlayer", "m", 600
    wb.add_resource "tile", "m2", 50
    assert wb.save, "Waybill is not saved"
    
    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 3, sh.length, "Storehouse entries is not equal to 2"

    dTo = Deal.new(:tag => "Test deal for money to asset exchange",
             :entity => Entity.new(:tag => "TestEntity"), :give => Asset.find_by_tag("underlayer"),
             :take => money(:rub), :rate => 15.0)
    assert dTo.save, "Deal is not created"

    assert Fact.new(:amount => 600, :day => DateTime.civil(2011, 5, 5, 12, 0, 0),
        :resource => Asset.find_by_tag("underlayer"),
        :from => Deal.find_all_by_entity_id_and_give_id_and_take_id(entities(:sergey),
          Asset.find_by_tag("underlayer"), Asset.find_by_tag("underlayer")).first,
        :to => dTo).save, "Fact is not saved"
      
    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 2, sh.length, "Storehouse entries is not equal to 2"
    sh.each do |item|
      assert item.instance_of?(StorehouseEntry), "Wrong storehouse entry type"
      if item.product == Product.find_by_resource_id(assets(:sonyvaio))
        assert_equal 10, item.amount, "Wrong storehouse entry amount"
        assert_equal entities(:sergey), item.owner, "Wrong storehouse entity"
        assert_equal Place.find_by_tag("Some test place"), item.place, "Wrong storehouse entity"
      elsif item.product == Product.find_by_resource_tag("tile")
        assert_equal 50, item.amount, "Wrong storehouse entry amount"
        assert_equal entities(:sergey), item.owner, "Wrong storehouse entity"
        assert_equal Place.find_by_tag("Some test place"), item.place, "Wrong storehouse entity"
      else
        assert false, "Unknown storehouse entry resource"
      end
    end
  end

  test "check amounts" do
    assert Place.new(:tag => "Some test place").save, "Entity not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 200, sh[0].amount, "Wrong roof amount"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 150, sh[0].amount, "Wrong roof amount"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 6, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 100, sh[0].amount, "Wrong roof amount"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 7, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"), false)
    assert_equal 0, sh.length, "Wrong storehouse length"

    assert sr.cancel, "Storehouse release is not closed"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 100, sh[0].amount, "Wrong roof amount"
  end

  test "storehouse show only by entity and place" do
    assert Place.new(:tag => "Some test place").save, "Entity not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 1, Storehouse.new.length, "Wrong storehouse length"

    assert Entity.new(:tag => "Second storekeeper").save, "Entity is not saved"
    wb = Waybill.new(:owner => Entity.find_by_tag("Second storekeeper"),
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 2, Storehouse.new.length, "Wrong storehouse length"
    sh = Storehouse.new(Entity.find_by_tag("Second storekeeper"),
      Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
  end

  test "show one resource for two waybills" do
    assert Place.new(:tag => "Some test place").save, "Entity not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"

    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
  end
end
