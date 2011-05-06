require 'test_helper'

class StorehouseReleaseTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "validate neccessary fields" do
    assert StorehouseRelease.new.invalid?, "Invalid storehaouse release"
    assert StorehouseRelease.new(:created => DateTime.now).invalid?,
      "StorehouseRelease with created field is invalid"
    sr = StorehouseRelease.new(:created => DateTime.now, :owner => Entity.new(:tag => "Test1Entity"),
      :to => Entity.new(:tag => "Test2Entity"))
    assert sr.invalid?, "StorehouseRelease is invalid"
    sr.add_resource(Asset.new(:tag => "Resource1"), 2)
    assert sr.valid?, "StorehouseRelease is valid"
    assert sr.save, "StorehouseRelease is not saved"

    assert_equal 1, StorehouseRelease.all.count, "StorehouseRelease count is not equal to 1"
    assert_equal StorehouseRelease::INWORK, StorehouseRelease.first.state, "State is not equal to inwork"
  end

  test "to as text" do
    sh = StorehouseRelease.new :created => DateTime.now, :owner => Entity.new(:tag => "Test1Entity")
    sh.to = Entity.new(:tag => "HelloWorld1")
    sh.add_resource(Asset.new(:tag => "Resource1"), 2)
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
    sr = StorehouseRelease.new(:created => DateTime.now, :owner => Entity.new(:tag => "Test1Entity"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(Asset.new(:tag => "Resource1"), 2)
    assert sr.save, "StorehouseRelease is not saved"
    
    assert sr.cancel, "StorehouseRelease is not canceled"
    assert_equal StorehouseRelease::CANCELED, StorehouseRelease.first.state, "State is not equal to canceled"
  end

  test "apply" do
    sr = StorehouseRelease.new(:created => DateTime.now, :owner => Entity.new(:tag => "Test1Entity"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(Asset.new(:tag => "Resource1"), 2)
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
end
