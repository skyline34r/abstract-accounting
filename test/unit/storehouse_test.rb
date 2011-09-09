
require "test_helper"

class StorehouseTest < ActiveSupport::TestCase
  test "assign attributes to storehouse" do
    d = Deal.new(:tag => "Test deal for money to asset exchange",
             :entity => entities(:sergey), :give => money(:rub),
             :take => assets(:sonyvaio), :rate => 1.0)
    assert d.save, "Deal is not created"
    sr = Storehouse.new :owner_id => entities(:sergey).id, :place_id => places(:orsha).id,
                        :deal_id => d.id, :real_amount => 10.0, :exp_amount => 0.0,
                        :product_id => products(:sonyv).id
    assert_equal entities(:sergey).id, sr.owner_id, "Wrong storehouse owner id"
    assert_equal entities(:sergey), sr.owner, "Wrong storehouse owner"
    assert_equal places(:orsha).id, sr.place_id, "Wrong storehouse place id"
    assert_equal places(:orsha), sr.place, "Wrong storehouse place"
    assert_equal d.id, sr.deal_id, "Wrong storehouse deal id"
    assert_equal d, sr.deal, "Wrong storehouse deal"
    assert_equal products(:sonyv).id, sr.product_id, "Wrong storehouse product id"
    assert_equal products(:sonyv), sr.product, "Wrong storehouse product"
    assert_equal 10.0, sr.real_amount, "Wrong storehouse amount"
    assert_equal 0.0, sr.exp_amount, "Wrong storehouse exp_amount"
  end

  test "check storehouse contain only storage deals" do
    assert_equal 0, Storehouse.all.length, "Wrong storehouse length"

    assert Deal.new(:tag => "Test deal for money to asset exchange",
             :entity => entities(:sergey), :give => money(:rub),
             :take => assets(:sonyvaio), :rate => 1.0).save, "Deal is not created"
    assert Deal.new(:tag => "Test deal for money to money exchange",
             :entity => entities(:sergey), :give => money(:rub),
             :take => money(:eur), :rate => 1.0).save, "Deal is not created"
    assert Deal.new(:tag => "Test deal for asset to money exchange",
             :entity => entities(:sergey), :give => assets(:sonyvaio),
             :take => money(:rub), :rate => 1.0).save, "Deal is not created"

    assert_equal 0, Storehouse.all.length, "Wrong storehouse length"

    assert Place.new(:tag => "Some test place").save, "Entity not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "128345",
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    wb.add_resource "underlayer", "m", 600
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all
    assert_equal 2, sh.length, "Storehouse entries is not equal to 2"
    sh.each do |item|
      assert item.instance_of?(Storehouse), "Wrong storehouse entry type"
      assert_equal Place.find_by_tag("Some test place"), item.place, "Wrong place"
      if item.product == Product.find_by_resource_id(assets(:sonyvaio))
        assert_equal 10, item.real_amount, "Wrong storehouse entry real_amount"
        assert_equal 10, item.exp_amount, "Wrong storehouse entry exp_amount"
      elsif item.product == Product.find_by_resource_tag("underlayer")
        assert_equal 600, item.real_amount, "Wrong storehouse entry real_amount"
        assert_equal 600, item.exp_amount, "Wrong storehouse entry exp_amount"
      else
        assert false, "Unknown storehouse entry resource"
      end
    end
  end

  test "storehouse do not show deals with empty state" do
    assert Place.new(:tag => "Some test place").save, "Entity not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "128345",
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    wb.add_resource "underlayer", "m", 600
    wb.add_resource "tile", "m2", 50
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 3, sh.length, "Storehouse entries is not equal to 2"

    dTo = Deal.new(:tag => "Test deal for money to asset exchange",
             :entity => Entity.new(:tag => "TestEntity"), :give => Asset.find_by_tag("underlayer"),
             :take => money(:rub), :rate => 15.0)
    assert dTo.save, "Deal is not created"

    dt_now = DateTime.now
    assert Fact.new(:amount => 600,
        :day => DateTime.civil(dt_now.year, dt_now.month, dt_now.day, 12, 0, 0),
        :resource => Asset.find_by_tag("underlayer"),
        :from => Deal.find_all_by_entity_id_and_give_id_and_take_id(entities(:sergey),
          Asset.find_by_tag("underlayer"), Asset.find_by_tag("underlayer")).first,
        :to => dTo).save, "Fact is not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 2, sh.length, "Storehouse entries is not equal to 2"
    sh.each do |item|
      assert item.instance_of?(Storehouse), "Wrong storehouse entry type"
      if item.product == Product.find_by_resource_id(assets(:sonyvaio))
        assert_equal 10, item.real_amount, "Wrong storehouse entry real_amount"
        assert_equal 10, item.exp_amount, "Wrong storehouse entry exp_amount"
        assert_equal entities(:sergey), item.owner, "Wrong storehouse entity"
        assert_equal Place.find_by_tag("Some test place"), item.place, "Wrong storehouse entity"
      elsif item.product == Product.find_by_resource_tag("tile")
        assert_equal 50, item.real_amount, "Wrong storehouse entry real_amount"
        assert_equal 50, item.exp_amount, "Wrong storehouse entry exp_amount"
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
      :document_id => "128345",
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 200, sh[0].real_amount, "Wrong roof real_amount"
    assert_equal 200, sh[0].exp_amount, "Wrong roof exp_amount"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.new(:tag => "Test2Entity"))
    sr.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 200, sh[0].real_amount, "Wrong roof real_amount"
    assert_equal 150, sh[0].exp_amount, "Wrong roof exp_amount"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 6, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_tag("roof"), 50
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 200, sh[0].real_amount, "Wrong roof real_amount"
    assert_equal 100, sh[0].exp_amount, "Wrong roof exp_amount"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 7, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => Entity.find_by_tag("Test2Entity"))
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"),
                        :check_amount => false)
    assert_equal 0, sh.length, "Wrong storehouse length"

    assert sr.cancel, "Storehouse release is not closed"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 200, sh[0].real_amount, "Wrong roof real_amount"
    assert_equal 100, sh[0].exp_amount, "Wrong roof exp_amount"
  end

  test "storehouse show only by entity and place" do
    assert Place.new(:tag => "Some test place").save, "Entity not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "128345",
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 1, Storehouse.all.length, "Wrong storehouse length"

    assert Entity.new(:tag => "Second storekeeper").save, "Entity is not saved"
    wb = Waybill.new(:owner => Entity.find_by_tag("Second storekeeper"),
      :document_id => "1283456",
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 2, Storehouse.all.length, "Wrong storehouse length"
    sh = Storehouse.all(:entity => Entity.find_by_tag("Second storekeeper"),
                        :place => Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
  end

  test "show one resource for two waybills" do
    assert Place.new(:tag => "Some test place").save, "Entity not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "128345",
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "1283456",
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
  end

  test "real amount for two waybills" do
    assert Place.new(:tag => "Some test place").save, "Entity not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "128345",
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 200, sh[0].exp_amount, "Wrong storehouse exp_amount"
    assert_equal 200, sh[0].real_amount, "Wrong storehouse real_amount"

    assert Entity.new(:tag => "Some entity for test").save, "Entity not saved"
    assert Place.new(:tag => "Some test place 2").save, "Place not saved"
    wb = Waybill.new(:owner => Entity.find_by_tag("Some entity for test"),
      :document_id => "1283456",
      :place => Place.find_by_tag("Some test place 2"),
      :from => "Some organization 2",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 230
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all(:entity => Entity.find_by_tag("Some entity for test"),
                        :place => Place.find_by_tag("Some test place 2"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 230, sh[0].exp_amount, "Wrong storehouse exp_amount"
    assert_equal 230, sh[0].real_amount, "Wrong storehouse amount"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 200, sh[0].exp_amount, "Wrong storehouse exp_amount"
    assert_equal 200, sh[0].real_amount, "Wrong storehouse amount"

    sh = Storehouse.all
    assert_equal 2, sh.length, "Wrong storehouse length"
    assert_equal 200, sh[0].exp_amount, "Wrong storehouse amount"
    assert_equal 200, sh[0].real_amount, "Wrong storehouse amount"
    assert_equal 230, sh[1].exp_amount, "Wrong storehouse amount"
    assert_equal 230, sh[1].real_amount, "Wrong storehouse amount"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 7, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => "Test2Entity")
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.all(:entity => Entity.find_by_tag("Some entity for test"),
                        :place => Place.find_by_tag("Some test place 2"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 230, sh[0].exp_amount, "Wrong storehouse amount"
    assert_equal 230, sh[0].real_amount, "Wrong storehouse amount"

    sh = Storehouse.all(:entity => entities(:sergey), :place => Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 100, sh[0].exp_amount, "Wrong storehouse amount"
    assert_equal 200, sh[0].real_amount, "Wrong storehouse amount"

    sh = Storehouse.all
    assert_equal 2, sh.length, "Wrong storehouse length"
    assert_equal 100, sh[0].exp_amount, "Wrong storehouse amount"
    assert_equal 200, sh[0].real_amount, "Wrong storehouse amount"
    assert_equal 230, sh[1].exp_amount, "Wrong storehouse amount"
    assert_equal 230, sh[1].real_amount, "Wrong storehouse amount"
  end

  test "check where" do
    p = Place.new(:tag => "Storehouse")
    assert p.save, "Place not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "12345",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 9, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "123456",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 10, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    wb.add_resource "shovel", "th", 100
    assert wb.save, "Waybill is not saved"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "1234567",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 11, 12, 0, 0))
    wb.add_resource "shovel", "th", 50
    assert wb.save, "Waybill is not saved"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "12345678",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 11, 12, 0, 0))
    wb.add_resource "gloves", "th", 100
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => p)
    assert_equal 3, sh.length, "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:entity => entities(:sergey), :place => p,
                                   :where => {'product.resource.tag' => {:like => "sho"}}).length,
                 "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:entity => entities(:sergey), :place => p,
                                   :where => {'product.resource.tag' => {:like => "el"}}).length,
                 "Wrong storehouse length"
    assert_equal 2, Storehouse.all(:entity => entities(:sergey), :place => p,
                                   :where => {'product.resource.tag' => {:like => "ov"}}).length,
                 "Wrong storehouse length"
    assert_equal 3, Storehouse.all(:entity => entities(:sergey), :place => p,
                                   :where => {'product.resource.tag' => {:like => "o"}}).length,
                 "Wrong storehouse length"
    assert_equal 2, Storehouse.all(:entity => entities(:sergey), :place => p,
                                   :where => {'product.unit' => {:like => "th"}}).length,
                 "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:entity => entities(:sergey), :place => p,
                                   :where => {'exp_amount' => {:like => 150}}).length,
                 "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:entity => entities(:sergey), :place => p,
                                   :where => {'exp_amount' => {:like => 150.00}}).length,
                 "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:entity => entities(:sergey), :place => p,
                                   :where => {'exp_amount' => {:like => "150"}}).length,
                 "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:entity => entities(:sergey), :place => p,
                                   :where => {'exp_amount' => {:like => 15}}).length,
                 "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:entity => entities(:sergey), :place => p,
                                   :where => {'exp_amount' => {:like => "15"}}).length,
                 "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:where => {'real_amount' => {:like => 400}}).length,
                 "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:where => {'real_amount' => {:like => 400.00}}).length,
                 "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:where => {'real_amount' => {:like => "400"}}).length,
                 "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:where => {'real_amount' => {:like => 4}}).length,
                 "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:where => {'real_amount' => {:like => "40"}}).length,
                 "Wrong storehouse length"
    assert_equal 3, Storehouse.all(:where => {'place.tag' => {:like => "HOUSE"}}).length,
                 "Wrong storehouse length"
    assert_equal 3, Storehouse.all(:where => {'place.tag' => {:like => "h"}}).length,
                 "Wrong storehouse length"
    assert_equal 3, Storehouse.all(:where => {'place.tag' => {:like => "store"}}).length,
                 "Wrong storehouse length"
    assert_equal 3, Storehouse.all(:where => {'place.tag' => {:like => "Storehouse"}}).length,
                 "Wrong storehouse length"
    assert_equal 3, Storehouse.all(:where => {'place.tag' => {:like => "storehouse"}}).length,
                 "Wrong storehouse length"
    assert_equal 0, Storehouse.all(:where => {'place.tag' => {:like => "storehouse1"}}).length,
                 "Wrong storehouse length"
    assert_equal 1, Storehouse.all(:entity => entities(:sergey), :place => p,
                                   :where => {'product.unit' => {:like => "t"},
                                              'product.resource.tag' => {:like => "gl"}}).length,
                 "Wrong storehouse length"
    assert_equal 2, Storehouse.all(:entity => entities(:sergey), :place => p,
                                   :where => {'product.unit' => {:like => "t"},
                                              'exp_amount' => {:like => "1"}}).length,
                 "Wrong storehouse length"
  end

  test "check order" do
    p = Place.new(:tag => "Storehouse")
    assert p.save, "Place not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "12345",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 9, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "123456",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 10, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    wb.add_resource "shovel", "th", 100
    assert wb.save, "Waybill is not saved"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "1234567",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 11, 12, 0, 0))
    wb.add_resource "shovel", "th", 50
    assert wb.save, "Waybill is not saved"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "12345678",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 11, 12, 0, 0))
    wb.add_resource "gloves", "th", 100
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all(:entity => entities(:sergey), :place => p)
    assert_equal 3, sh.length, "Wrong storehouse length"
    sh = Storehouse.all :entity => entities(:sergey), :place => p, :order => { 'place.tag' => 'asc' }
    sh.each do |item|
      assert_equal p.tag, item.place.tag
    end
    sh = Storehouse.all :entity => entities(:sergey), :place => p, :order => { 'product.resource.tag' => 'asc' }
    assert_equal "gloves", sh[0].product.resource.tag, "Wrong resource tag"
    assert_equal "roof", sh[1].product.resource.tag, "Wrong resource tag"
    assert_equal "shovel", sh[2].product.resource.tag, "Wrong resource tag"
    sh = Storehouse.all :entity => entities(:sergey), :place => p, :order => { 'product.unit' => 'asc' }
    assert_equal "m2", sh[0].product.unit, "Wrong product unit"
    assert_equal "th", sh[1].product.unit, "Wrong product unit"
    assert_equal "th", sh[2].product.unit, "Wrong product unit"
    sh = Storehouse.all :entity => entities(:sergey), :place => p, :order => { 'exp_amount' => 'asc' }
    assert_equal 100, sh[0].exp_amount, "Wrong exp_amount"
    assert_equal 150, sh[1].exp_amount, "Wrong exp_amount"
    assert_equal 400, sh[2].exp_amount, "Wrong exp_amount"
    sh = Storehouse.all :entity => entities(:sergey), :place => p, :order => { 'real_amount' => 'desc' }
    assert_equal 100, sh[2].real_amount, "Wrong real_amount"
    assert_equal 150, sh[1].real_amount, "Wrong real_amount"
    assert_equal 400, sh[0].real_amount, "Wrong real_amount"
  end

  test "check paginate" do
    p = Place.new(:tag => "Storehouse")
    assert p.save, "Place not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "12345",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 9, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "123456",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 10, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    wb.add_resource "shovel", "th", 100
    assert wb.save, "Waybill is not saved"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "1234567",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 11, 12, 0, 0))
    wb.add_resource "shovel", "th", 50
    assert wb.save, "Waybill is not saved"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "12345678",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 11, 12, 0, 0))
    wb.add_resource "gloves", "th", 100
    assert wb.save, "Waybill is not saved"

    assert_equal 3, Storehouse.all.length, "Wrong storehouse length"
    sh = Storehouse.all(:order => {'product.resource.tag' => 'asc'},
                                   :page => 1, :per_page => 2)
    assert_equal 2, sh.length, "Wrong storehouse length"
    assert_equal "gloves", sh[0].product.resource.tag, "Wrong resource tag"
    assert_equal "roof", sh[1].product.resource.tag, "Wrong resource tag"
    sh = Storehouse.all(:order => {'product.resource.tag' => 'asc'},
                                   :page => "2", :per_page => "2")
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal "shovel", sh[0].product.resource.tag, "Wrong resource tag"
    assert_equal 3, Storehouse.all(:page => "1", :per_page => 4).length, "Wrong storehouse length"
  end

  test "check view storehouse resources float amount" do
    storekeeper = Entity.new(:tag => "Storekeeper")
    assert storekeeper.save, "Entity not saved"
    storehouse = Place.new(:tag => "Some storehouse")
    assert storehouse.save, "Entity not saved"

    wb = Waybill.new(:owner => storekeeper,
      :document_id => "12834",
      :place => storehouse,
      :from => "Organization Store",
      :created => DateTime.civil(2011, 8, 17, 12, 0, 0))
    wb.add_resource "carpet", "th", 12.3
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 8, 18, 12, 0, 0),
      :owner => storekeeper,
      :place => storehouse,
      :to => "Taskmaster")
    sr.add_resource Product.find_by_resource_tag("carpet"), 2.2
    assert sr.save, "StorehouseRelease not saved"

    storehouse = Storehouse.all(:entity => storekeeper,
                                :place => storehouse,
                                :check_amount => false)
    assert_equal 10.1, storehouse[0].exp_amount, "Wrong storehouse entry amount"
  end

  #test "check storehouse for taskmasters" do
  #  stm = Storehouse.taskmasters entities(:sergey), places(:orsha)
  #  assert_equal entities(:sergey), stm.entity, "Wrong storehouse entity"
  #  assert_equal places(:orsha), stm.place, "Wrong storehouse place"
  #  assert_equal 0, stm.length, "Wrong storehouse length"
  #
  #  wb = Waybill.new(:owner => entities(:sergey),
  #    :document_id => "12345",
  #    :place => places(:orsha),
  #    :from => "Storehouse organization",
  #    :created => DateTime.civil(2011, 4, 9, 12, 0, 0))
  #  wb.add_resource "roof", "m2", 200
  #  assert wb.save, "Waybill is not saved"
  #
  #  wb = Waybill.new(:owner => entities(:sergey),
  #    :document_id => "123456",
  #    :place => places(:orsha),
  #    :from => "Storehouse organization",
  #    :created => DateTime.civil(2011, 4, 10, 12, 0, 0))
  #  wb.add_resource "roof", "m2", 200
  #  wb.add_resource "shovel", "th", 100
  #  assert wb.save, "Waybill is not saved"
  #
  #  wb = Waybill.new(:owner => entities(:sergey),
  #    :document_id => "1234567",
  #    :place => places(:orsha),
  #    :from => "Storehouse organization",
  #    :created => DateTime.civil(2011, 4, 11, 12, 0, 0))
  #  wb.add_resource "shovel", "th", 50
  #  assert wb.save, "Waybill is not saved"
  #
  #  stm = Storehouse.taskmasters entities(:sergey), places(:orsha)
  #  assert_equal 0, stm.length, "Wrong storehouse length"
  #
  #  sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 12, 12, 0, 0),
  #    :owner => entities(:sergey),
  #    :place => places(:orsha),
  #    :to => entities(:jdow))
  #  sr.add_resource Product.find_by_resource_tag("roof"), 238
  #  assert sr.save, "StorehouseRelease not saved"
  #  assert sr.apply, "StorehouseRelease not applied"
  #
  #  stm = Storehouse.taskmasters entities(:sergey), places(:orsha)
  #  assert_equal 1, stm.length, "Wrong storehouse length"
  #  assert_equal 238, stm[0].amount, "Wrong storehouse amount"
  #  assert_equal Product.find_by_resource_tag("roof").id, stm[0].product.id,
  #               "Wrong storehouse product"
  #  assert_equal entities(:jdow).id, stm[0].owner.id, "Wrong storehouse owner"
  #
  #  sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 13, 12, 0, 0),
  #    :owner => entities(:sergey),
  #    :place => places(:orsha),
  #    :to => entities(:jdow))
  #  sr.add_resource Product.find_by_resource_tag("shovel"), 55
  #  assert sr.save, "StorehouseRelease not saved"
  #  assert sr.apply, "StorehouseRelease not applied"
  #
  #  stm = Storehouse.taskmasters entities(:sergey), places(:orsha)
  #  assert_equal 2, stm.length, "Wrong storehouse length"
  #  stm.each do |entry|
  #    if entry.product.id == Product.find_by_resource_tag("roof").id
  #      assert_equal 238, entry.amount, "Wrong storehouse amount"
  #    elsif entry.product.id == Product.find_by_resource_tag("shovel").id
  #      assert_equal 55, entry.amount, "Wrong storehouse amount"
  #    else
  #      assert false, "Wrong storehouse entry"
  #    end
  #  end
  #
  #  sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 14, 12, 0, 0),
  #    :owner => entities(:sergey),
  #    :place => places(:orsha),
  #    :to => entities(:jdow))
  #  sr.add_resource Product.find_by_resource_tag("shovel"), 55
  #  assert sr.save, "StorehouseRelease not saved"
  #  assert sr.apply, "StorehouseRelease not applied"
  #
  #  sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 14, 12, 0, 0),
  #    :owner => entities(:sergey),
  #    :place => places(:orsha),
  #    :to => "StorehouseRelease")
  #  sr.add_resource Product.find_by_resource_tag("shovel"), 20
  #  assert sr.save, "StorehouseRelease not saved"
  #  assert sr.apply, "StorehouseRelease not applied"
  #
  #  stm = Storehouse.taskmasters entities(:sergey), places(:orsha)
  #  assert_equal 3, stm.length, "Wrong storehouse length"
  #  stm.each do |entry|
  #    if entry.product.id == Product.find_by_resource_tag("roof").id
  #      assert_equal 238, entry.amount, "Wrong storehouse amount"
  #    elsif entry.product.id == Product.find_by_resource_tag("shovel").id
  #      if entry.owner.id == entities(:jdow).id
  #        assert_equal 110, entry.amount, "Wrong storehouse amount"
  #      elsif entry.owner.id == Entity.find_by_tag("StorehouseRelease").id
  #        assert_equal 20, entry.amount, "Wrong storehouse amount"
  #      else
  #        assert false, "Unknown entity"
  #      end
  #    else
  #      assert false, "Wrong storehouse entry"
  #    end
  #  end
  #
  #  stm = Storehouse.taskmaster entities(:jdow), places(:orsha)
  #  assert_equal 2, stm.length, "Wrong storehouse length"
  #  stm.each do |entry|
  #    if entry.product.id == Product.find_by_resource_tag("roof").id
  #      assert_equal 238, entry.amount, "Wrong storehouse amount"
  #    elsif entry.product.id == Product.find_by_resource_tag("shovel").id
  #      assert_equal 110, entry.amount, "Wrong storehouse amount"
  #    else
  #      assert false, "Wrong storehouse entry"
  #    end
  #  end
  #end
  #
  #test "check storehouse state after return" do
  #  storekeeper = Entity.new(:tag => "Storekeeper")
  #  assert storekeeper.save, "Entity not saved"
  #  warehouse = Place.new(:tag => "Some warehouse")
  #  assert warehouse.save, "Entity not saved"
  #  taskmaster = Entity.new :tag => "Taskmaster"
  #  assert taskmaster.save, "Entity is not saved"
  #
  #  wb = Waybill.new(:owner => storekeeper,
  #    :document_id => "12834",
  #    :place => warehouse,
  #    :from => "Organization Store",
  #    :created => DateTime.civil(2011, 4, 2, 12, 0, 0))
  #  wb.add_resource assets(:sonyvaio).tag, "th", 100
  #  assert wb.save, "Waybill is not saved"
  #
  #  sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 3, 12, 0, 0),
  #    :owner => storekeeper,
  #    :place => warehouse,
  #    :to => taskmaster)
  #  sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 30
  #  assert sr.save, "StorehouseRelease not saved"
  #  assert sr.apply, "Storehouse release is not applied"
  #
  #  sh = Storehouse.new storekeeper, warehouse
  #  assert_equal 1, sh.length, "Wrong storehouse length"
  #  assert_equal 70, sh[0].amount, "Wrong storehouse amount"
  #  assert_equal 70, sh[0].real_amount, "Wrong storehouse amount"
  #
  #  sh = Storehouse.taskmasters storekeeper, warehouse
  #  assert_equal 1, sh.length, "Wrong storehouse length"
  #  assert_equal 30, sh[0].amount, "Wrong storehouse amount"
  #
  #  sh = Storehouse.taskmaster taskmaster, warehouse
  #  assert_equal 1, sh.length, "Wrong storehouse length"
  #  assert_equal 30, sh[0].amount, "Wrong storehouse amount"
  #
  #  sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 4, 12, 0, 0),
  #      :from => taskmaster,
  #      :to => storekeeper,
  #      :place => warehouse
  #  sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 10
  #  assert sr.save, "StorehouseReturn not saved"
  #
  #  sh = Storehouse.new storekeeper, warehouse
  #  assert_equal 1, sh.length, "Wrong storehouse length"
  #  assert_equal 80, sh[0].amount, "Wrong storehouse amount"
  #  assert_equal 80, sh[0].real_amount, "Wrong storehouse amount"
  #
  #  sh = Storehouse.taskmasters storekeeper, warehouse
  #  assert_equal 1, sh.length, "Wrong storehouse length"
  #  assert_equal 20, sh[0].amount, "Wrong storehouse amount"
  #
  #  sh = Storehouse.taskmaster taskmaster, warehouse
  #  assert_equal 1, sh.length, "Wrong storehouse length"
  #  assert_equal 20, sh[0].amount, "Wrong storehouse amount"
  #
  #  sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
  #    :owner => storekeeper,
  #    :place => warehouse,
  #    :to => taskmaster)
  #  sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 30
  #  assert sr.save, "StorehouseRelease not saved"
  #
  #  sh = Storehouse.new storekeeper, warehouse
  #  assert_equal 1, sh.length, "Wrong storehouse length"
  #  assert_equal 50, sh[0].amount, "Wrong storehouse amount"
  #  assert_equal 80, sh[0].real_amount, "Wrong storehouse amount"
  #
  #  sh = Storehouse.taskmasters storekeeper, warehouse
  #  assert_equal 1, sh.length, "Wrong storehouse length"
  #  assert_equal 20, sh[0].amount, "Wrong storehouse amount"
  #
  #  sh = Storehouse.taskmaster taskmaster, warehouse
  #  assert_equal 1, sh.length, "Wrong storehouse length"
  #  assert_equal 20, sh[0].amount, "Wrong storehouse amount"
  #end
  #
  test "group storehouses entry by resource" do
    storekeeper = Entity.new(:tag => "Storekeeper")
    assert storekeeper.save, "Entity not saved"
    warehouse = Place.new(:tag => "Some warehouse")
    assert warehouse.save, "Entity not saved"

    wb = Waybill.new(:owner => storekeeper,
      :document_id => "12834",
      :place => warehouse,
      :from => "Organization Store",
      :created => DateTime.civil(2011, 4, 2, 12, 0, 0))
    wb.add_resource assets(:sonyvaio).tag, "th", 100
    assert wb.save, "Waybill is not saved"

    wb = Waybill.new(:owner => storekeeper,
      :document_id => "12345",
      :place => warehouse,
      :from => "Organization Store 2",
      :created => DateTime.civil(2011, 4, 2, 12, 0, 0))
    wb.add_resource "sony VAI O", "th", 150
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all :entity => storekeeper, :place => warehouse
    assert_equal 2, sh.length, "Wrong storehouse length"
    assert_equal 100, sh[0].exp_amount, "Wrong storehouse amount"
    assert_equal 100, sh[0].real_amount, "Wrong storehouse amount"
    assert_equal assets(:sonyvaio).tag, sh[0].product.resource.real_tag, "Wrong resource tag"
    assert_equal 150, sh[1].exp_amount, "Wrong storehouse amount"
    assert_equal 150, sh[1].real_amount, "Wrong storehouse amount"
    assert_equal "sony VAI O", sh[1].product.resource.real_tag, "Wrong resource tag"

    a = asset_reals(:notebooksv)
    a.assets << Asset.find_by_tag("sony VAI O")
    a.assets << assets(:sonyvaio)

    sh = Storehouse.all :entity => storekeeper, :place => warehouse
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 250, sh[0].exp_amount, "Wrong storehouse amount"
    assert_equal 250, sh[0].real_amount, "Wrong storehouse amount"
    assert_equal asset_reals(:notebooksv).tag, sh[0].product.resource.real_tag, "Wrong resource tag"

    wb = Waybill.new(:owner => storekeeper,
      :document_id => "123456",
      :place => warehouse,
      :from => "Organization Store 3",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "sony 3D", "th", 50
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all :entity => storekeeper, :place => warehouse
    assert_equal 2, sh.length, "Wrong storehouse length"
    sh.each do |entry|
      if entry.owner.id == storekeeper.id
        if asset_reals(:notebooksv).tag == entry.product.resource.real_tag
          assert_equal 250, entry.exp_amount, "Wrong storehouse amount"
          assert_equal 250, entry.real_amount, "Wrong storehouse amount"
        elsif "sony 3D" == entry.product.resource.real_tag
          assert_equal 50, entry.exp_amount, "Wrong storehouse amount"
          assert_equal 50, entry.real_amount, "Wrong storehouse amount"
        else
          assert false, "Unknown resource"
        end
      else
        assert false, "Unknown owner id"
      end
    end

    sh = Storehouse.all
    assert_equal 2, sh.length, "Wrong storehouse length"
    sh.each do |entry|
      if entry.owner.id == storekeeper.id
        if asset_reals(:notebooksv).tag == entry.product.resource.real_tag
          assert_equal 250, entry.exp_amount, "Wrong storehouse amount"
          assert_equal 250, entry.real_amount, "Wrong storehouse amount"
        elsif "sony 3D" == entry.product.resource.real_tag
          assert_equal 50, entry.exp_amount, "Wrong storehouse amount"
          assert_equal 50, entry.real_amount, "Wrong storehouse amount"
        else
          assert false, "Unknown resource"
        end
      else
        assert false, "Unknown owner id"
      end
    end

    storekeeper2 = Entity.new(:tag => "Storekeeper2")
    assert storekeeper2.save, "Entity not saved"
    warehouse2 = Place.new(:tag => "Some warehouse2")
    assert warehouse2.save, "Entity not saved"

    wb = Waybill.new(:owner => storekeeper2,
      :document_id => "128347",
      :place => warehouse2,
      :from => "Organization Store 5",
      :created => DateTime.civil(2011, 4, 8, 12, 0, 0))
    wb.add_resource assets(:sonyvaio).tag, "th", 100
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.all
    assert_equal 3, sh.length, "Wrong storehouse length"
    sh.each do |entry|
      if entry.owner.id == storekeeper.id
        if asset_reals(:notebooksv).tag == entry.product.resource.real_tag
          assert_equal 250, entry.exp_amount, "Wrong storehouse amount"
          assert_equal 250, entry.real_amount, "Wrong storehouse amount"
        elsif "sony 3D" == entry.product.resource.real_tag
          assert_equal 50, entry.exp_amount, "Wrong storehouse amount"
          assert_equal 50, entry.real_amount, "Wrong storehouse amount"
        else
          assert false, "Unknown resource"
        end
      elsif entry.owner.id == storekeeper2.id
        if asset_reals(:notebooksv).tag == entry.product.resource.real_tag
          assert_equal 100, entry.exp_amount, "Wrong storehouse amount"
          assert_equal 100, entry.real_amount, "Wrong storehouse amount"
        else
          assert false, "Unknown resource"
        end
      else
        assert false, "Unknown owner id"
      end
    end
  end
end
