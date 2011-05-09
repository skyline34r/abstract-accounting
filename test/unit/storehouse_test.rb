
require "test_helper"

class StorehouseTest < ActiveSupport::TestCase
  test "assign entity to storehouse" do
    assert_equal entities(:sergey), Storehouse.new(entities(:sergey)).entity, "Entity is wrong"
    assert_equal nil, Storehouse.new(1).entity, "Entity is wrong"
  end

  test "check storehouse contain only storage deals" do
    assert_equal 0, Storehouse.new(entities(:sergey)).length, "Wrong storehouse length"

    assert Deal.new(:tag => "Test deal for money to asset exchange",
             :entity => entities(:sergey), :give => money(:rub),
             :take => assets(:sonyvaio), :rate => 1.0).save, "Deal is not created"
    assert Deal.new(:tag => "Test deal for money to money exchange",
             :entity => entities(:sergey), :give => money(:rub),
             :take => money(:eur), :rate => 1.0).save, "Deal is not created"
    assert Deal.new(:tag => "Test deal for asset to money exchange",
             :entity => entities(:sergey), :give => assets(:sonyvaio),
             :take => money(:rub), :rate => 1.0).save, "Deal is not created"

    assert_equal 0, Storehouse.new(entities(:sergey)).length, "Wrong storehouse length"

    assert Waybill.new(:date => DateTime.civil(2011, 5, 3, 12, 0, 0),
      :owner => entities(:sergey), :organization => Entity.new(:tag => "Some organization"),
      :place => Place.new(:tag => "Some test place"),
      :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
        :unit => "th", :amount => 10), WaybillEntry.new(:resource => Asset.new(:tag => "underlayer"),
        :unit => "m", :amount => 600)]).save, "Waybill is not saved"

    sh = Storehouse.new(entities(:sergey))
    assert_equal 2, sh.length, "Storehouse entries is not equal to 2"
    sh.each do |item|
      assert item.instance_of?(StorehouseEntry), "Wrong storehouse entry type"
      if item.resource == assets(:sonyvaio)
        assert_equal 10, item.amount, "Wrong storehouse entry amount"
      elsif item.resource == Asset.find_by_tag("underlayer")
        assert_equal 600, item.amount, "Wrong storehouse entry amount"
      else
        assert false, "Unknown storehouse entry resource"
      end
    end
  end

  test "storehouse do not show deals with empty state" do

    assert Place.new(:tag => "Some test place").save, "Place is not saved"
    user = User.new(:email => "user@mail.com",
                 :password => "user_pass",
                 :password_confirmation => "user_pass",
                 :entity_id => entities(:sergey).id,
                 :role_ids => [roles(:operator).id])
    user.place = Place.find_by_tag("Some test place")
    assert user.save, "User is not saved"
    assert Waybill.new(:date => DateTime.civil(2011, 5, 3, 12, 0, 0),
      :owner => entities(:sergey), :organization => Entity.new(:tag => "Some organization"),
      :place => Place.find_by_tag("Some test place"),
      :waybill_entries => [WaybillEntry.new(:resource => assets(:sonyvaio),
        :unit => "th", :amount => 10), WaybillEntry.new(:resource => Asset.new(:tag => "underlayer"),
        :unit => "m", :amount => 600), WaybillEntry.new(:resource => Asset.new(:tag => "tile"),
        :unit => "m2", :amount => 50)]).save, "Waybill is not saved"

    sh = Storehouse.new(entities(:sergey))
    assert_equal 3, sh.length, "Storehouse entries is not equal to 2"

    dTo = Deal.new(:tag => "Test deal for money to asset exchange",
             :entity => Entity.new(:tag => "TestEntity"), :give => Asset.find_by_tag("underlayer"),
             :take => money(:rub), :rate => 15.0)
    assert dTo.save, "Deal is not created"

    assert Fact.new(:amount => 600, :day => DateTime.civil(2011, 5, 5, 12, 0, 0),
        :resource => Asset.find_by_tag("underlayer"),
        :from => Deal.find_all_by_entity_id_and_give_id_and_take_id(entities(:sergey), Asset.find_by_tag("underlayer"), Asset.find_by_tag("underlayer")).first,
        :to => dTo).save, "Fact is not saved"
    sh = Storehouse.new(entities(:sergey))
    assert_equal 2, sh.length, "Storehouse entries is not equal to 2"
    sh.each do |item|
      assert item.instance_of?(StorehouseEntry), "Wrong storehouse entry type"
      if item.resource == assets(:sonyvaio)
        assert_equal 10, item.amount, "Wrong storehouse entry amount"
        assert_equal entities(:sergey), item.owner, "Wrong storehouse entity"
        assert_equal Place.find_by_tag("Some test place"), item.place, "Wrong storehouse entity"
      elsif item.resource == Asset.find_by_tag("tile")
        assert_equal 50, item.amount, "Wrong storehouse entry amount"
        assert_equal entities(:sergey), item.owner, "Wrong storehouse entity"
        assert_equal Place.find_by_tag("Some test place"), item.place, "Wrong storehouse entity"
      else
        assert false, "Unknown storehouse entry resource"
      end
    end
  end

  test "check amounts" do
    wb = Waybill.new(:date => DateTime.civil(2011, 4, 5, 12, 0, 0), :owner => entities(:sergey),
              :place => Place.new(:tag => "Some test place"),
              :waybill_entries => [WaybillEntry.new(:resource => Asset.new(:tag => "roof"),
              :unit => "m2", :amount => 200)])
    wb.assign_organization_text("Test Organization Store")
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.new(entities(:sergey))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 200, sh[0].amount, "Wrong roof amount"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 2, 12, 0, 0),
      :place => Place.find_by_tag("Some test place"),
      :owner => entities(:sergey), :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource(Asset.find_by_tag("roof"), 50)
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.new(entities(:sergey))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 150, sh[0].amount, "Wrong roof amount"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 3, 12, 0, 0),
      :place => Place.find_by_tag("Some test place"),
      :owner => entities(:sergey), :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource(Asset.find_by_tag("roof"), 50)
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.new(entities(:sergey))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 100, sh[0].amount, "Wrong roof amount"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 4, 12, 0, 0),
      :place => Place.find_by_tag("Some test place"),
      :owner => entities(:sergey), :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource(Asset.find_by_tag("roof"), 100)
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.new(entities(:sergey))
    assert_equal 0, sh.length, "Wrong storehouse length"

    assert sr.cancel, "Storehouse release is not closed"

    sh = Storehouse.new(entities(:sergey))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 100, sh[0].amount, "Wrong roof amount"
  end
end
