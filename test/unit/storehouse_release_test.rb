require 'test_helper'

class StorehouseReleaseTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "validate neccessary fields" do
    assert StorehouseRelease.new.invalid?, "Invalid storehaouse release"
    assert StorehouseRelease.new(:created => DateTime.now).invalid?,
      "StorehouseRelease with created field is invalid"
    assert StorehouseRelease.new(:created => DateTime.now, :owner => Entity.new(:tag => "Test1Entity"),
      :to => Entity.new(:tag => "Test2Entity")).valid?, "StorehouseRelease is valid"
    assert StorehouseRelease.new(:created => DateTime.now, :owner => Entity.new(:tag => "Test1Entity"),
      :to => Entity.new(:tag => "Test2Entity")).save, "StorehouseRelease is not saved"

    assert_equal 1, StorehouseRelease.all.count, "StorehouseRelease count is not equal to 1"
    assert_equal StorehouseRelease::INWORK, StorehouseRelease.first.state, "State is not equal to inwork"
  end

  test "to as text" do
    sh = StorehouseRelease.new :created => DateTime.now, :owner => Entity.new(:tag => "Test1Entity")
    sh.to = Entity.new(:tag => "HelloWorld1")
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
    assert StorehouseRelease.new(:created => DateTime.now, :owner => Entity.new(:tag => "Test1Entity"),
      :to => Entity.new(:tag => "Test2Entity")).save, "StorehouseRelease is not saved"
    
    assert StorehouseRelease.first.cancel, "StorehouseRelease is not canceled"
    assert_equal StorehouseRelease::CANCELED, StorehouseRelease.first.state, "State is not equal to canceled"
  end

  test "apply" do
    assert StorehouseRelease.new(:created => DateTime.now, :owner => Entity.new(:tag => "Test1Entity"),
      :to => Entity.new(:tag => "Test2Entity")).save, "StorehouseRelease is not saved"

    assert StorehouseRelease.first.apply, "StorehouseRelease is not applied"
    assert_equal StorehouseRelease::APPLIED, StorehouseRelease.first.state, "State is not equal to applied"
  end
end
