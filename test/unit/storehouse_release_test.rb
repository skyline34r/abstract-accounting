require 'test_helper'

class StorehouseReleaseTest < ActiveSupport::TestCase
  def setup
    wb = Waybill.new(:date => DateTime.civil(2011, 4, 4, 12, 0, 0), :owner => entities(:sergey),
              :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
              :unit => "th", :amount => 10)])
    wb.assign_organization_text("Test Organization Store")
    wb.save
  end

  test "validate neccessary fields" do
    assert StorehouseRelease.new.invalid?, "Invalid storehaouse release"
    assert StorehouseRelease.new(:created => DateTime.now).invalid?,
      "StorehouseRelease with created field is invalid"
    sr = StorehouseRelease.new(:created => DateTime.now, :owner => Entity.new(:tag => "Test1Entity"),
      :to => Entity.new(:tag => "Test2Entity"))
    assert sr.invalid?, "StorehouseRelease is invalid"
    sr.add_resource(Asset.new(:tag => "Resource1"), 2)
    assert sr.invalid?, "StorehouseRelease is invalid"
    sr = StorehouseRelease.new(:created => DateTime.now, :owner => entities(:sergey),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 11)
    assert sr.invalid?, "StorehouseRelease is invalid"

    sr = StorehouseRelease.new(:created => DateTime.now, :owner => entities(:sergey),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 0)
    assert sr.invalid?, "StorehouseRelease is invalid"

    assert Asset.new(:tag => "Test resource").save, "Asset is not saved"
    assert Deal.new(:tag => "test deal for check validation", :entity => entities(:sergey),
      :give => Asset.find_by_tag("Test resource"), :take => Asset.find_by_tag("Test resource"),
      :rate => 1.0).save, "Deal is not saved"
    sr = StorehouseRelease.new(:created => DateTime.now, :owner => entities(:sergey),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(Asset.find_by_tag("Test resource"), 3)
    assert sr.invalid?, "StorehouseRelease is invalid"

    sr = StorehouseRelease.new(:created => DateTime.now, :owner => entities(:sergey),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 9)
    sr.add_resource(Asset.new(:tag => "some unknown resource"), 1)
    assert sr.invalid?, "StorehouseRelease is invalid"
    sr = StorehouseRelease.new(:created => DateTime.now, :owner => entities(:sergey),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 9)
    assert sr.valid?, "StorehouseRelease is valid"
    assert sr.save, "StorehouseRelease is not saved"

    assert_equal 1, StorehouseRelease.all.count, "StorehouseRelease count is not equal to 1"
    assert_equal StorehouseRelease::INWORK, StorehouseRelease.first.state, "State is not equal to inwork"
  end

  test "to as text" do
    sh = StorehouseRelease.new :created => DateTime.now, :owner => entities(:sergey)
    sh.to = Entity.new(:tag => "HelloWorld1")
    sh.add_resource(assets(:sonyvaio), 9)
    assert sh.to.instance_of?(Entity), "To field is not entity"
    assert sh.valid?, "Release is not valid"

    sh.to = "Hello2"
    assert sh.to.instance_of?(Entity), "To field is not entity"
    assert sh.valid?, "Release is not valid"

    e = Entity.new :tag => "TestEntity3"
    assert e.save, "Entity is not saved"

    sh.to = "testentity3"
    assert sh.to.instance_of?(Entity), "To field is not entity"
    assert_equal e.id, sh.to.id, "To id is wrong"
    assert sh.valid?, "Release is not valid"
  end

  test "cancel" do
    sr = StorehouseRelease.new(:created => DateTime.now, :owner => entities(:sergey),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 9)
    assert sr.save, "StorehouseRelease is not saved"
    
    assert sr.cancel, "StorehouseRelease is not canceled"
    assert_equal StorehouseRelease::CANCELED, StorehouseRelease.first.state, "State is not equal to canceled"
  end

  test "apply" do
    sr = StorehouseRelease.new(:created => DateTime.now, :owner => entities(:sergey),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 9)
    assert sr.save, "StorehouseRelease is not saved"

    assert sr.apply, "StorehouseRelease is not applied"
    assert_equal StorehouseRelease::APPLIED, StorehouseRelease.first.state, "State is not equal to applied"
  end

  test "entries" do
    sr = StorehouseRelease.new(:created => DateTime.now, :owner => Entity.new(:tag => "Test1Entity"),
      :to => Entity.new(:tag => "Test2Entity"))
    a = Asset.new(:tag => "hello")
    sr.add_resource(a, 28)

    assert_equal 1, sr.resources.length, "Resources count is not equal to 1"
    assert sr.resources[0].instance_of?(StorehouseReleaseEntry), "Unknown entry instance"
    assert_equal a, sr.resources[0].resource, "Wrong resource"
    assert_equal 28, sr.resources[0].amount, "Wrong amount"
    a = Asset.new(:tag => "hello2")
    sr.add_resource(a, 39)

    assert_equal 2, sr.resources.length, "Resources count is not equal to 2"
    assert sr.resources[1].instance_of?(StorehouseReleaseEntry), "Unknown entry instance"
    assert_equal a, sr.resources[1].resource, "Wrong resource"
    assert_equal 39, sr.resources[1].amount, "Wrong amount"
  end

  test "deals is created" do
    deals_count = Deal.all.count

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 4, 12, 0, 0),
      :owner => entities(:sergey), :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 3)
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

    wb = Waybill.new(:date => DateTime.civil(2011, 4, 5, 12, 0, 0), :owner => entities(:sergey),
              :waybill_entries => [WaybillEntry.new(:resource => Asset.new(:tag => "roof"),
              :unit => "m2", :amount => 200)])
    wb.assign_organization_text("Test Organization Store")
    assert wb.save, "Waybill is not saved"

    #recalculate count of deals
    deals_count = Deal.all.count

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => entities(:sergey), :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 1)
    sr.add_resource(Asset.find_by_tag("roof"), 100)
    assert sr.save, "StorehouseRelease not saved"

    deals_count += 2
    assert_equal deals_count, Deal.all.count, "Deal is not created"

    d = Deal.find_all_by_give_and_take_and_entity(Asset.find_by_tag("roof"),
      Asset.find_by_tag("roof"), Entity.find_by_tag("Test2Entity")).first
    assert !d.nil?, "Deal not found"

    sr = StorehouseRelease.new(:created => DateTime.now, :owner => entities(:sergey),
      :to => Entity.new(:tag => "Test3Entity"))
    sr.add_resource(assets(:sonyvaio), 3)
    sr.add_resource(Asset.find_by_tag("roof"), 100)
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
      :owner => entities(:sergey), :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 3)
    assert sr.save, "StorehouseRelease not saved"

    assert_equal 1, sr.deal.rules.count, "Wrong deal rules count"
    ownerDeal = sr.resources[0].storehouse_deal(sr.owner)
    toDeal = sr.resources[0].storehouse_deal(sr.to)
    rule = sr.deal.rules[0]
    assert_equal 3, rule.rate, "Wrong rule rate"
    assert_equal ownerDeal, rule.from, "Wrong rule from"
    assert_equal toDeal, rule.to, "Wrong rule to"

    wb = Waybill.new(:date => DateTime.civil(2011, 4, 5, 12, 0, 0), :owner => entities(:sergey),
              :waybill_entries => [WaybillEntry.new(:resource => Asset.new(:tag => "roof"),
              :unit => "m2", :amount => 200)])
    wb.assign_organization_text("Test Organization Store")
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => entities(:sergey), :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource(assets(:sonyvaio), 1)
    sr.add_resource(Asset.find_by_tag("roof"), 100)
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
end
