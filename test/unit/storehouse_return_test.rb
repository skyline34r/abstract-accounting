require 'test_helper'

class StorehouseReturnTest < ActiveSupport::TestCase
  def setup
    @storekeeper = Entity.new(:tag => "Storekeeper")
    assert @storekeeper.save, "Entity not saved"
    @warehouse = Place.new(:tag => "Some warehouse")
    assert @warehouse.save, "Entity not saved"
    @taskmaster = Entity.new :tag => "Taskmaster"
    assert @taskmaster.save, "Entity is not saved"

    wb = Waybill.new(:owner => @storekeeper,
      :document_id => "12834",
      :place => @warehouse,
      :from => "Organization Store",
      :created => DateTime.civil(2011, 4, 2, 12, 0, 0))
    wb.add_resource assets(:sonyvaio).tag, "th", 100
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 3, 12, 0, 0),
      :owner => @storekeeper,
      :place => @warehouse,
      :to => @taskmaster)
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 30
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "Storehouse release is not applied"
  end


  test "validate neccessary fields" do
    assert StorehouseReturn.new.invalid?, "Invalid storehaouse return"

    assert StorehouseReturn.new(:created_at => DateTime.now).invalid?,
      "StorehouseReturn with created field is invalid"

    sr = StorehouseReturn.new :created_at => DateTime.now,
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    assert sr.invalid?, "StorehouseReturn is invalid"

    sr.add_resource Product.new(:resource => "Resource1"), 2
    assert sr.invalid?, "StorehouseReturn is invalid"

    sr = StorehouseReturn.new :created_at => DateTime.now,
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 31
    assert sr.invalid?, "StorehouseReturn is invalid"

    sr = StorehouseReturn.new :created_at => DateTime.now,
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 0
    assert sr.invalid?, "StorehouseReturn is invalid"

    assert Asset.new(:tag => "Test resource").save, "Asset is not saved"
    assert Deal.new(:tag => "test deal for check validation", :entity => entities(:sergey),
      :give => Asset.find_by_tag("Test resource"), :take => Asset.find_by_tag("Test resource"),
      :rate => 1.0).save, "Deal is not saved"
    sr = StorehouseReturn.new :created_at => DateTime.now,
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.new(:resource => "Test resource", :unit => "th"), 3
    assert sr.invalid?, "StorehouseReturn is invalid"

    sr = StorehouseReturn.new :created_at => DateTime.now,
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    sr.add_resource Product.new(:resource => "some unknown resource", :unit => "th"), 1
    assert sr.invalid?, "StorehouseReturn is invalid"

    sr = StorehouseReturn.new :created_at => DateTime.now,
        :from => @taskmaster,
        :to => @storekeeper
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    assert sr.invalid?, "StorehouseReturn is invalid"

    sr = StorehouseReturn.new :created_at => DateTime.now,
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    assert sr.valid?, "StorehouseReturn is valid"
    assert sr.save, "StorehouseReturn is not saved"

    assert_equal 1, StorehouseReturn.all.count, "StorehouseReturn count is not equal to 1"
    assert_equal @warehouse, StorehouseReturn.first.place, "Wrong storehouse place"
  end

  test "entries" do
    sr = StorehouseReturn.new :created_at => DateTime.now,
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 19

    assert_equal 1, sr.resources.length, "Resources count is not equal to 1"
    assert sr.resources[0].instance_of?(StorehouseReturnEntry), "Unknown entry instance"
    assert_equal assets(:sonyvaio), sr.resources[0].product.resource, "Wrong resource"
    assert_equal 19, sr.resources[0].amount, "Wrong amount"
    sr.add_resource Product.new(:resource => "Second resource", :unit => "th"), 39

    assert_equal 2, sr.resources.length, "Resources count is not equal to 2"
    assert sr.resources[1].instance_of?(StorehouseReturnEntry), "Unknown entry instance"
    assert_equal "Second resource", sr.resources[1].product.resource.tag, "Wrong resource"
    assert_equal 39, sr.resources[1].amount, "Wrong amount"
  end

  test "deals is created" do
    deals_count = Deal.all.count

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 4, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    assert sr.save, "StorehouseReturn not saved"

    deals_count += 1
    assert_equal deals_count, Deal.all.count, "Deal is not created"
    d = Deal.find(sr.deal.id)
    assert !d.nil?, "Deal not found"
    assert_equal @taskmaster, d.entity, "Entity is not valid"
    assert_equal true, d.isOffBalance, "IsOffbalance is invalid"

    d = Deal.find_all_by_give_and_take_and_entity(assets(:sonyvaio),
      assets(:sonyvaio), @storekeeper).first
    assert !d.nil?, "Deal not found"
    assert_equal true, d.isOffBalance, "IsOffbalance is invalid"

    wb = Waybill.new(:owner => @storekeeper,
      :document_id => "128345",
      :place => @warehouse,
      :from => "Organization Store 2",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => @storekeeper,
      :place => @warehouse,
      :to => @taskmaster)
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "Storehouse release is not applied"

    #recalculate count of deals
    deals_count = Deal.all.count

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 5, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    sr.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr.save, "StorehouseReturn not saved"

    deals_count += 1
    assert_equal deals_count, Deal.all.count, "Deal is not created"

    d = Deal.find_all_by_give_and_take_and_entity(Asset.find_by_tag("roof"),
      Asset.find_by_tag("roof"), @storekeeper).first
    assert !d.nil?, "Deal not found"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 6, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    sr.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr.save, "StorehouseReturn not saved"

    deals_count += 1
    assert_equal deals_count, Deal.all.count, "Deal is not created"

    d = Deal.find_all_by_give_and_take_and_entity(assets(:sonyvaio),
      assets(:sonyvaio), @storekeeper).first
    assert !d.nil?, "Deal not found"

    d = Deal.find_all_by_give_and_take_and_entity(Asset.find_by_tag("roof"),
      Asset.find_by_tag("roof"), @storekeeper).first
    assert !d.nil?, "Deal not found"
  end

  test "rules is created" do
    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 4, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    assert sr.save, "StorehouseReturn not saved"

    assert_equal 1, sr.deal.rules.count, "Wrong deal rules count"
    from_deal = sr.resources[0].storehouse_deal(sr.from)
    to_deal = sr.resources[0].storehouse_deal(sr.to)
    rule = sr.deal.rules[0]
    assert_equal 9, rule.rate, "Wrong rule rate"
    assert_equal from_deal, rule.from, "Wrong rule from"
    assert_equal to_deal, rule.to, "Wrong rule to"

    wb = Waybill.new(:owner => @storekeeper,
      :document_id => "128345",
      :place => @warehouse,
      :from => "Organization Store 2",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => @storekeeper,
      :place => @warehouse,
      :to => @taskmaster)
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "Storehouse release is not applied"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 5, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    sr.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr.save, "StorehouseReturn not saved"

    assert_equal 2, sr.deal.rules.count, "Wrong deal rules count"
    from_deal = sr.resources[0].storehouse_deal(sr.from)
    to_deal = sr.resources[0].storehouse_deal(sr.to)
    rule = sr.deal.rules[0]
    assert_equal 9, rule.rate, "Wrong rule rate"
    assert_equal from_deal, rule.from, "Wrong rule from"
    assert_equal to_deal, rule.to, "Wrong rule to"
    from_deal = sr.resources[1].storehouse_deal(sr.from)
    to_deal = sr.resources[1].storehouse_deal(sr.to)
    rule = sr.deal.rules[1]
    assert_equal 50, rule.rate, "Wrong rule rate"
    assert_equal from_deal, rule.from, "Wrong rule from"
    assert_equal to_deal, rule.to, "Wrong rule to"
  end

  test "entries is loaded" do
    wb = Waybill.new(:owner => @storekeeper,
      :document_id => "128345",
      :place => @warehouse,
      :from => "Organization Store 2",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => @storekeeper,
      :place => @warehouse,
      :to => @taskmaster)
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "Storehouse release is not applied"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 5, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    sr.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr.save, "StorehouseReturn not saved"

    assert_equal 1, StorehouseReturn.all.count, "Wrong return count"
    sr = StorehouseReturn.first
    assert !sr.nil?, "return is nil"
    assert_equal 2, sr.resources.length, "Wrong return resources count"
    sr.resources.each do |item|
      if assets(:sonyvaio) == item.product.resource
        assert_equal 9, item.amount, "Wrong resource amount"
      elsif Asset.find_by_tag("roof") == item.product.resource
        assert_equal 50, item.amount, "Wrong resource amount"
      else
        assert false, "Unknown resource type"
      end
    end
  end

  test "after save - facts by rules" do
    wb = Waybill.new(:owner => @storekeeper,
      :document_id => "128345",
      :place => @warehouse,
      :from => "Organization Store 2",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => @storekeeper,
      :place => @warehouse,
      :to => @taskmaster)
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "Storehouse release is not applied"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 5, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 9
    sr.add_resource Product.find_by_resource_tag("roof"), 50

    from_sv_deal = sr.resources[0].storehouse_deal sr.from
    from_roof_deal = sr.resources[1].storehouse_deal sr.from

    assert_equal 30, from_sv_deal.state.amount, "Wrong resource amount"
    assert_equal 100, from_roof_deal.state.amount, "Wrong resource amount"

    assert sr.save, "StorehouseReturn not saved"

    assert_equal 21, from_sv_deal.state.amount, "Wrong resource amount"
    assert_equal 50, from_roof_deal.state.amount, "Wrong resource amount"
  end

  test "check is invalid for amount" do
    wb = Waybill.new(:owner => @storekeeper,
      :document_id => "128345",
      :place => @warehouse,
      :from => "Organization Store 2",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => @storekeeper,
      :place => @warehouse,
      :to => @taskmaster)
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "Storehouse release is not applied"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 5, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 10
    assert sr.save, "StorehouseReturn not saved"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 6, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr.save, "StorehouseReturn not saved"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 7, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 10
    sr.add_resource Product.find_by_resource_tag("roof"), 10
    assert sr.save, "StorehouseReturn not saved"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 8, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 8
    sr.add_resource Product.find_by_resource_tag("roof"), 31
    assert sr.save, "StorehouseReturn not saved"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 9, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_tag("roof"), 10
    assert sr.invalid?, "StorehouseReturn not valid"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 10, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 2
    assert sr.valid?, "StorehouseReturn valid"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 11, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 3
    assert sr.invalid?, "StorehouseReturn not valid"
  end

  test "check state by date" do
    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 4, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 2
    assert sr.valid?, "StorehouseReturn valid"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 2, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 2
    assert sr.invalid?, "StorehouseReturn not valid"

    wb = Waybill.new(:owner => @storekeeper,
      :document_id => "128345",
      :place => @warehouse,
      :from => "Organization Store 2",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => @storekeeper,
      :place => @warehouse,
      :to => @taskmaster)
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "Storehouse release is not applied"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 4, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 2
    assert sr.valid?, "StorehouseReturn valid"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 5, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 2
    sr.add_resource Product.find_by_resource_tag("roof"), 40
    assert sr.valid?, "StorehouseReturn valid"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 4, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 2
    sr.add_resource Product.find_by_resource_tag("roof"), 40
    assert sr.invalid?, "StorehouseReturn not valid"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 6, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 2
    sr.add_resource Product.find_by_resource_tag("roof"), 40
    assert sr.valid?, "StorehouseReturn valid"
  end

  test "check state by entity and place" do
    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 4, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 2
    assert sr.valid?, "StorehouseReturn valid"

    assert Entity.new(:tag => "Some entity 2").save, "Entity is not saved"
    wb = Waybill.new(:owner => @storekeeper,
      :document_id => "128345",
      :place => @warehouse,
      :from => "Organization Store 2",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource assets(:sonyvaio).tag, "th", 100
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => @storekeeper,
      :place => @warehouse,
      :to => Entity.find_by_tag("Some entity 2"))
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 10
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "Storehouse release is not applied"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 6, 12, 0, 0),
        :from => @taskmaster,
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 25
    assert sr.valid?, "StorehouseReturn valid"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 6, 12, 0, 0),
        :from => Entity.find_by_tag("Some entity 2"),
        :to => @storekeeper,
        :place => @warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 15
    assert sr.invalid?, "StorehouseReturn invalid"
  end
end
