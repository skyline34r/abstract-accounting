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

  test "deal is created" do
    deals_count = Deal.all.count

    sr = StorehouseRelease.new(:created => DateTime.now, :owner => entities(:sergey),
      :to => Entity.new(:tag => "Test2Entity"))
    a = assets(:sonyvaio)
    sr.add_resource(assets(:sonyvaio), 9)
    assert sr.save, "StorehouseRelease not saved"

    deals_count += 1
    assert_equal deals_count, Deal.all.count, "Deal is not created"
    d = Deal.find(sr.deal.id)
    assert !d.nil?, "Deal not found"
    assert_equal entities(:sergey), d.entity, "Entity is not valid"
    assert_equal true, d.isOffBalance, "IsOffbalance is invalid"
  end
end
