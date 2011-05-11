require 'test_helper'

class StorehouseReleaseTest < ActiveSupport::TestCase
  def setup
    assert Entity.new(:tag => "Storekeeper").save, "Entity not saved"
    assert Place.new(:tag => "Some test place").save, "Entity not saved"
    
    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Test Organization Store",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    assert wb.save, "Waybill is not saved"
  end

  test "validate neccessary fields" do
    assert Entity.new(:tag => "Test1Entity").save, "Entity not saved"
    assert Entity.new(:tag => "Test2Entity").save, "Entity not saved"

    assert StorehouseRelease.new.invalid?, "Invalid storehaouse release"

    assert StorehouseRelease.new(:created => DateTime.now).invalid?,
      "StorehouseRelease with created field is invalid"

    sr = StorehouseRelease.new(:created => DateTime.now,
      :owner => Entity.find_by_tag("Test1Entity"),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    assert sr.invalid?, "StorehouseRelease is invalid"

    sr.add_resource Product.new(:resource => "Resource1"), 2
    assert sr.invalid?, "StorehouseRelease is invalid"

    sr = StorehouseRelease.new(:created => DateTime.now,
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 11
    assert sr.invalid?, "StorehouseRelease is invalid"

    sr = StorehouseRelease.new(:created => DateTime.now,
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 0
    assert sr.invalid?, "StorehouseRelease is invalid"

    assert Asset.new(:tag => "Test resource").save, "Asset is not saved"
    assert Deal.new(:tag => "test deal for check validation", :entity => entities(:sergey),
      :give => Asset.find_by_tag("Test resource"), :take => Asset.find_by_tag("Test resource"),
      :rate => 1.0).save, "Deal is not saved"
    sr = StorehouseRelease.new(:created => DateTime.now,
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.new(:resource => "Test resource", :unit => "th"), 3
    assert sr.invalid?, "StorehouseRelease is invalid"

    sr = StorehouseRelease.new(:created => DateTime.now,
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    sr.add_resource Product.new(:resource => "some unknown resource", :unit => "th"), 1
    assert sr.invalid?, "StorehouseRelease is invalid"
    
    sr = StorehouseRelease.new(:created => DateTime.now,
      :owner => entities(:sergey),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    assert sr.invalid?, "StorehouseRelease is invalid"
    
    sr = StorehouseRelease.new(:created => DateTime.now,
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    assert sr.valid?, "StorehouseRelease is valid"
    assert sr.save, "StorehouseRelease is not saved"

    assert_equal 1, StorehouseRelease.all.count, "StorehouseRelease count is not equal to 1"
    assert_equal Place.find_by_tag("Some test place"), StorehouseRelease.first.place, "Wrong storehouse place"
    assert_equal StorehouseRelease::INWORK, StorehouseRelease.first.state, "State is not equal to inwork"
  end

  test "to as text" do
    sr = StorehouseRelease.new(:created => DateTime.now,
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "HelloWorld1"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    assert sr.to.instance_of?(Entity), "To field is not entity"
    assert sr.valid?, "Release is not valid"

    sr.to = "Hello2"
    assert sr.to.instance_of?(Entity), "To field is not entity"
    assert sr.valid?, "Release is not valid"

    e = Entity.new :tag => "TestEntity3"
    assert e.save, "Entity is not saved"

    sr.to = "testentity3"
    assert sr.to.instance_of?(Entity), "To field is not entity"
    assert_equal e.id, sr.to.id, "To id is wrong"
    assert sr.valid?, "Release is not valid"
  end

  test "cancel" do
    sr = StorehouseRelease.new(:created => DateTime.now,
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    assert sr.save, "StorehouseRelease is not saved"

    assert sr.cancel, "StorehouseRelease is not canceled"
    assert_equal StorehouseRelease::CANCELED, StorehouseRelease.first.state, "State is not equal to canceled"
  end

  test "apply" do
    sr = StorehouseRelease.new(:created => DateTime.now,
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    assert sr.save, "StorehouseRelease is not saved"

    assert sr.apply, "StorehouseRelease is not applied"
    assert_equal StorehouseRelease::APPLIED, StorehouseRelease.first.state, "State is not equal to applied"
  end

  test "entries" do
    sr = StorehouseRelease.new(:created => DateTime.now,
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9

    assert_equal 1, sr.resources.length, "Resources count is not equal to 1"
    assert sr.resources[0].instance_of?(StorehouseReleaseEntry), "Unknown entry instance"
    assert_equal assets(:sonyvaio), sr.resources[0].product.resource, "Wrong resource"
    assert_equal 9, sr.resources[0].amount, "Wrong amount"
    sr.add_resource Product.new(:resource => "Second resource", :unit => "th"), 39

    assert_equal 2, sr.resources.length, "Resources count is not equal to 2"
    assert sr.resources[1].instance_of?(StorehouseReleaseEntry), "Unknown entry instance"
    assert_equal "Second resource", sr.resources[1].product.resource.tag, "Wrong resource"
    assert_equal 39, sr.resources[1].amount, "Wrong amount"
  end

  test "deals is created" do
    deals_count = Deal.all.count

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 4, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 3
    assert sr.save, "StorehouseRelease not saved"

    deals_count += 2
    assert_equal deals_count, Deal.all.count, "Deal is not created"
    d = Deal.find(sr.deal.id)
    assert !d.nil?, "Deal not found"
    assert_equal entities(:sergey), d.entity, "Entity is not valid"
    assert_equal true, d.isOffBalance, "IsOffbalance is invalid"

    d = Deal.find_all_by_give_and_take_and_entity(assets(:sonyvaio),
      assets(:sonyvaio), Entity.find_by_tag("Test2Entity")).first
    assert !d.nil?, "Deal not found"
    assert_equal true, d.isOffBalance, "IsOffbalance is invalid"

    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Test Organization Store",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    #recalculate count of deals
    deals_count = Deal.all.count

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 1
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"

    deals_count += 2
    assert_equal deals_count, Deal.all.count, "Deal is not created"

    d = Deal.find_all_by_give_and_take_and_entity(Asset.find_by_tag("roof"),
      Asset.find_by_tag("roof"), Entity.find_by_tag("Test2Entity")).first
    assert !d.nil?, "Deal not found"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 6, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "Test3Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 3
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"

    deals_count += 3
    assert_equal deals_count, Deal.all.count, "Deal is not created"

    d = Deal.find_all_by_give_and_take_and_entity(assets(:sonyvaio),
      assets(:sonyvaio), Entity.find_by_tag("Test3Entity")).first
    assert !d.nil?, "Deal not found"

    d = Deal.find_all_by_give_and_take_and_entity(Asset.find_by_tag("roof"),
      Asset.find_by_tag("roof"), Entity.find_by_tag("Test3Entity")).first
    assert !d.nil?, "Deal not found"
  end

  test "rules is created" do
    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 4, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 3
    assert sr.save, "StorehouseRelease not saved"

    assert_equal 1, sr.deal.rules.count, "Wrong deal rules count"
    ownerDeal = sr.resources[0].storehouse_deal(sr.owner)
    toDeal = sr.resources[0].storehouse_deal(sr.to)
    rule = sr.deal.rules[0]
    assert_equal 3, rule.rate, "Wrong rule rate"
    assert_equal ownerDeal, rule.from, "Wrong rule from"
    assert_equal toDeal, rule.to, "Wrong rule to"

    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Test Organization Store",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 1
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"

    assert_equal 2, sr.deal.rules.count, "Wrong deal rules count"
    ownerDeal = sr.resources[0].storehouse_deal(sr.owner)
    toDeal = sr.resources[0].storehouse_deal(sr.to)
    rule = sr.deal.rules[0]
    assert_equal 1, rule.rate, "Wrong rule rate"
    assert_equal ownerDeal, rule.from, "Wrong rule from"
    assert_equal toDeal, rule.to, "Wrong rule to"
    ownerDeal = sr.resources[1].storehouse_deal(sr.owner)
    toDeal = sr.resources[1].storehouse_deal(sr.to)
    rule = sr.deal.rules[1]
    assert_equal 100, rule.rate, "Wrong rule rate"
    assert_equal ownerDeal, rule.from, "Wrong rule from"
    assert_equal toDeal, rule.to, "Wrong rule to"
  end

  test "entries is loaded" do
    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Test Organization Store",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 1
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"

    assert_equal 1, StorehouseRelease.all.count, "Wrong releases count"
    sr = StorehouseRelease.first
    assert !sr.nil?, "Release is nil"
    assert_equal 2, sr.resources.length, "Wrong release resources count"
    sr.resources.each do |item|
      if assets(:sonyvaio) == item.product.resource
        assert_equal 1, item.amount, "Wrong resource amount"
      elsif Asset.find_by_tag("roof") == item.product.resource
        assert_equal 100, item.amount, "Wrong resource amount"
      else
        assert false, "Unknown resource type"
      end
    end
  end

  test "get all inwork releases" do
    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Test Organization Store",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    srs = StorehouseRelease.inwork
    assert_equal 0, srs.length, "Wrong inwork releases count"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 1
    assert sr.save, "StorehouseRelease not saved"

    sr1 = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 6, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr1.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 1
    sr1.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr1.save, "StorehouseRelease not saved"

    sr2 = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 7, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr2.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 4
    sr2.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr2.save, "StorehouseRelease not saved"

    sr3 = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 7, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr3.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 1
    sr3.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr3.save, "StorehouseRelease not saved"

    srs = StorehouseRelease.inwork
    assert_equal 4, srs.length, "Wrong inwork releases count"

    assert sr1.apply, "Release is not applied"
    assert sr3.cancel, "Release is not canceled"

    srs = StorehouseRelease.inwork
    assert_equal 2, srs.length, "Wrong inwork releases count"
  end

  test "after apply - facts by rules" do
    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Test Organization Store",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    srs = StorehouseRelease.inwork
    assert_equal 0, srs.length, "Wrong inwork releases count"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 1
    sr.add_resource Product.find_by_resource_tag("roof"), 50

    ownerSVDeal = sr.resources[0].storehouse_deal sr.owner
    ownerRoofDeal = sr.resources[1].storehouse_deal sr.owner

    assert_equal 10, ownerSVDeal.state.amount, "Wrong resource amount"
    assert_equal 200, ownerRoofDeal.state.amount, "Wrong resource amount"

    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "StorehouseRelease not applied"

    assert_equal 9, ownerSVDeal.state.amount, "Wrong resource amount"
    assert_equal 150, ownerRoofDeal.state.amount, "Wrong resource amount"
  end

  test "check is invalid for amount" do
    wb = Waybill.new(:owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :from => "Test Organization Store",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 1
    assert sr.save, "StorehouseRelease not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 6, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 1
    sr.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr.save, "StorehouseRelease not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 7, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 4
    sr.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr.save, "StorehouseRelease not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 8, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 1
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 9, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_tag("roof"), 10
    assert sr.invalid?, "StorehouseRelease is valid"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 10, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 3
    assert sr.valid?, "StorehouseRelease is invalid"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 11, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 4
    assert sr.invalid?, "StorehouseRelease is valid"
  end
end
