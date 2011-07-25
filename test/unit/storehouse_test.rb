
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
      :document_id => "128345",
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
      :document_id => "128345",
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

    dt_now = DateTime.now
    assert Fact.new(:amount => 600,
        :day => DateTime.civil(dt_now.year, dt_now.month, dt_now.day, 12, 0, 0),
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
      :document_id => "128345",
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
      :document_id => "128345",
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
      :document_id => "1283456",
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
      :document_id => "128345",
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "1283456",
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
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

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 200, sh[0].amount, "Wrong storehouse amount"
    assert_equal 200, sh[0].real_amount, "Wrong storehouse amount"

    assert Entity.new(:tag => "Some entity for test").save, "Entity not saved"
    assert Place.new(:tag => "Some test place 2").save, "Place not saved"
    wb = Waybill.new(:owner => Entity.find_by_tag("Some entity for test"),
      :document_id => "1283456",
      :place => Place.find_by_tag("Some test place 2"),
      :from => "Some organization 2",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "roof", "m2", 230
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.new(Entity.find_by_tag("Some entity for test"),
                        Place.find_by_tag("Some test place 2"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 230, sh[0].amount, "Wrong storehouse amount"
    assert_equal 230, sh[0].real_amount, "Wrong storehouse amount"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 200, sh[0].amount, "Wrong storehouse amount"
    assert_equal 200, sh[0].real_amount, "Wrong storehouse amount"

    sh = Storehouse.new
    assert_equal 2, sh.length, "Wrong storehouse length"
    assert_equal 200, sh[0].amount, "Wrong storehouse amount"
    assert_equal 200, sh[0].real_amount, "Wrong storehouse amount"
    assert_equal 230, sh[1].amount, "Wrong storehouse amount"
    assert_equal 230, sh[1].real_amount, "Wrong storehouse amount"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 7, 12, 0, 0),
      :owner => entities(:sergey),
      :place => Place.find_by_tag("Some test place"),
      :to => "Test2Entity")
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.new(Entity.find_by_tag("Some entity for test"),
                        Place.find_by_tag("Some test place 2"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 230, sh[0].amount, "Wrong storehouse amount"
    assert_equal 230, sh[0].real_amount, "Wrong storehouse amount"

    sh = Storehouse.new(entities(:sergey), Place.find_by_tag("Some test place"))
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 100, sh[0].amount, "Wrong storehouse amount"
    assert_equal 200, sh[0].real_amount, "Wrong storehouse amount"

    sh = Storehouse.new
    assert_equal 2, sh.length, "Wrong storehouse length"
    assert_equal 100, sh[0].amount, "Wrong storehouse amount"
    assert_equal 200, sh[0].real_amount, "Wrong storehouse amount"
    assert_equal 230, sh[1].amount, "Wrong storehouse amount"
    assert_equal 230, sh[1].real_amount, "Wrong storehouse amount"
  end

  test "get waybills for storehouse" do
    p = Place.new(:tag => "Storehouse")
    assert p.save, "Place not saved"
    wb1 = Waybill.new(:owner => entities(:sergey),
      :document_id => "12345",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb1.add_resource "roof", "m2", 200
    assert wb1.save, "Waybill is not saved"

    wb2 = Waybill.new(:owner => entities(:sergey),
      :document_id => "123456",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb2.add_resource "roof", "m2", 200
    wb2.add_resource "shovel", "th", 100
    assert wb2.save, "Waybill is not saved"

    wb3 = Waybill.new(:owner => entities(:sergey),
      :document_id => "1234567",
      :place => p,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 6, 12, 0, 0))
    wb3.add_resource "shovel", "th", 50
    assert wb3.save, "Waybill is not saved"

    sh = Storehouse.new(entities(:sergey), p)
    assert_equal 2, sh.length, "Wrong storehouse length"
    sh_waybills = sh.waybills
    assert_equal 3, sh_waybills.length, "Wrong waybills count"
    sh_waybills.each do |item|
      assert item.instance_of?(StorehouseWaybill), "Unknown instance"
      assert !item.resources.nil?, "Wrong resources"
      if item.waybill.id == wb1.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "roof"
            assert_equal 200, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      elsif item.waybill.id == wb2.id
        assert_equal 2, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "roof"
            assert_equal 200, sw.amount, "Wrong resource amount"
          elsif sw.product.resource.tag == "shovel"
            assert_equal 100, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      elsif item.waybill.id == wb3.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "shovel"
            assert_equal 50, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      else
        assert false, "Unknown waybill"
      end
    end

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 7, 12, 0, 0),
      :owner => entities(:sergey),
      :place => p,
      :to => "Taskmaster")
    sr.add_resource Product.find_by_resource_tag("roof"), 100
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.new(entities(:sergey), p)
    assert_equal 2, sh.length, "Wrong storehouse length"
    sh_waybills = sh.waybills
    assert_equal 3, sh_waybills.length, "Wrong waybills count"
    sh_waybills.each do |item|
      assert item.instance_of?(StorehouseWaybill), "Unknown instance"
      assert !item.resources.nil?, "Wrong resources"
      if item.waybill.id == wb1.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "roof"
            assert_equal 100, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      elsif item.waybill.id == wb2.id
        assert_equal 2, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "roof"
            assert_equal 200, sw.amount, "Wrong resource amount"
          elsif sw.product.resource.tag == "shovel"
            assert_equal 100, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      elsif item.waybill.id == wb3.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "shovel"
            assert_equal 50, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      else
        assert false, "Unknown waybill"
      end
    end

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 8, 12, 0, 0),
      :owner => entities(:sergey),
      :place => p,
      :to => "Taskmaster")
    sr.add_resource Product.find_by_resource_tag("roof"), 102
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.new(entities(:sergey), p)
    assert_equal 2, sh.length, "Wrong storehouse length"
    sh_waybills = sh.waybills
    assert_equal 2, sh_waybills.length, "Wrong waybills count"
    sh_waybills.each do |item|
      assert item.instance_of?(StorehouseWaybill), "Unknown instance"
      assert !item.resources.nil?, "Wrong resources"
      if item.waybill.id == wb2.id
        assert_equal 2, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "roof"
            assert_equal 198, sw.amount, "Wrong resource amount"
          elsif sw.product.resource.tag == "shovel"
            assert_equal 100, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      elsif item.waybill.id == wb3.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "shovel"
            assert_equal 50, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      else
        assert false, "Unknown waybill"
      end
    end

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 9, 12, 0, 0),
      :owner => entities(:sergey),
      :place => p,
      :to => "Taskmaster")
    sr.add_resource Product.find_by_resource_tag("shovel"), 102
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.new(entities(:sergey), p)
    assert_equal 2, sh.length, "Wrong storehouse length"
    sh_waybills = sh.waybills
    assert_equal 2, sh_waybills.length, "Wrong waybills count"
    sh_waybills.each do |item|
      assert item.instance_of?(StorehouseWaybill), "Unknown instance"
      assert !item.resources.nil?, "Wrong resources"
      if item.waybill.id == wb2.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "roof"
            assert_equal 198, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      elsif item.waybill.id == wb3.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "shovel"
            assert_equal 48, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      else
        assert false, "Unknown waybill"
      end
    end

    e = Entity.new(:tag => "Storekeeper 2")
    assert e.save, "Entity is not saved"
    p1 = Place.new :tag => "Storehouse 2"
    assert p1.save, "Place is not saved"

    wb4 = Waybill.new(:owner => e,
      :document_id => "123456789",
      :place => p1,
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 8, 12, 0, 0))
    wb4.add_resource "roof", "m2", 130
    assert wb4.save, "Waybill is not saved"

    sh = Storehouse.new(entities(:sergey), p)
    assert_equal 2, sh.length, "Wrong storehouse length"
    sh_waybills = sh.waybills
    assert_equal 2, sh_waybills.length, "Wrong waybills count"
    sh_waybills.each do |item|
      assert item.instance_of?(StorehouseWaybill), "Unknown instance"
      assert !item.resources.nil?, "Wrong resources"
      if item.waybill.id == wb2.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "roof"
            assert_equal 198, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      elsif item.waybill.id == wb3.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "shovel"
            assert_equal 48, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      else
        assert false, "Unknown waybill"
      end
    end

    sh = Storehouse.new e, p1
    assert_equal 1, sh.length, "Wrong storehouse length"
    sh_waybills = sh.waybills
    assert_equal 1, sh_waybills.length, "Wrong waybills count"
    sh_waybills.each do |item|
      assert item.instance_of?(StorehouseWaybill), "Unknown instance"
      assert !item.resources.nil?, "Wrong resources"
      if item.waybill.id == wb4.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "roof"
            assert_equal 130, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      else
        assert false, "Unknown waybill"
      end
    end

    assert !sh.waybill_by_id(wb4.id).nil?, "Waybill is nil"
    assert sh.waybill_by_id(wb4.id - 1).nil?, "Waybill is not nil"
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

    sh = Storehouse.new entities(:sergey), p
    assert_equal 2, sh.length, "Wrong storehouse length"
    assert_equal 1, sh.where('product.resource.tag' => {:like => "sho"}).length,
                 "Wrong storehouse length"
    assert_equal 1, sh.where('product.resource.tag' => {:like => "el"}).length,
                 "Wrong storehouse length"
    assert_equal 1, sh.where('product.resource.tag' => {:like => "ov"}).length,
                 "Wrong storehouse length"
    assert_equal 2, sh.where('product.resource.tag' => {:like => "o"}).length,
                 "Wrong storehouse length"
    assert_equal 1, sh.where('product.unit' => {:like => "th"}).length,
                 "Wrong storehouse length"
    assert_equal 1, sh.where('amount' => {:like => 150}).length,
                 "Wrong storehouse length"
    assert_equal 1, sh.where('amount' => {:like => 150.00}).length,
                 "Wrong storehouse length"
    assert_equal 1, sh.where('amount' => {:like => "150"}).length,
                 "Wrong storehouse length"
    assert_equal 1, sh.where('amount' => {:like => 15}).length,
                 "Wrong storehouse length"
    assert_equal 1, sh.where('amount' => {:like => "15"}).length,
                 "Wrong storehouse length"
  end

  test "check storehouse for taskmasters" do
    stm = Storehouse.taskmasters entities(:sergey), places(:orsha)
    assert_equal entities(:sergey), stm.entity, "Wrong storehouse entity"
    assert_equal places(:orsha), stm.place, "Wrong storehouse place"
    assert_equal 0, stm.length, "Wrong storehouse length"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "12345",
      :place => places(:orsha),
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 9, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    assert wb.save, "Waybill is not saved"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "123456",
      :place => places(:orsha),
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 10, 12, 0, 0))
    wb.add_resource "roof", "m2", 200
    wb.add_resource "shovel", "th", 100
    assert wb.save, "Waybill is not saved"

    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "1234567",
      :place => places(:orsha),
      :from => "Storehouse organization",
      :created => DateTime.civil(2011, 4, 11, 12, 0, 0))
    wb.add_resource "shovel", "th", 50
    assert wb.save, "Waybill is not saved"

    stm = Storehouse.taskmasters entities(:sergey), places(:orsha)
    assert_equal 0, stm.length, "Wrong storehouse length"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 12, 12, 0, 0),
      :owner => entities(:sergey),
      :place => places(:orsha),
      :to => entities(:jdow))
    sr.add_resource Product.find_by_resource_tag("roof"), 238
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "StorehouseRelease not applied"

    stm = Storehouse.taskmasters entities(:sergey), places(:orsha)
    assert_equal 1, stm.length, "Wrong storehouse length"
    assert_equal 238, stm[0].amount, "Wrong storehouse amount"
    assert_equal Product.find_by_resource_tag("roof").id, stm[0].product.id,
                 "Wrong storehouse product"
    assert_equal entities(:jdow).id, stm[0].owner.id, "Wrong storehouse owner"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 13, 12, 0, 0),
      :owner => entities(:sergey),
      :place => places(:orsha),
      :to => entities(:jdow))
    sr.add_resource Product.find_by_resource_tag("shovel"), 55
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "StorehouseRelease not applied"

    stm = Storehouse.taskmasters entities(:sergey), places(:orsha)
    assert_equal 2, stm.length, "Wrong storehouse length"
    stm.each do |entry|
      if entry.product.id == Product.find_by_resource_tag("roof").id
        assert_equal 238, entry.amount, "Wrong storehouse amount"
      elsif entry.product.id == Product.find_by_resource_tag("shovel").id
        assert_equal 55, entry.amount, "Wrong storehouse amount"
      else
        assert false, "Wrong storehouse entry"
      end
    end

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 14, 12, 0, 0),
      :owner => entities(:sergey),
      :place => places(:orsha),
      :to => entities(:jdow))
    sr.add_resource Product.find_by_resource_tag("shovel"), 55
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "StorehouseRelease not applied"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 14, 12, 0, 0),
      :owner => entities(:sergey),
      :place => places(:orsha),
      :to => "StorehouseRelease")
    sr.add_resource Product.find_by_resource_tag("shovel"), 20
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "StorehouseRelease not applied"

    stm = Storehouse.taskmasters entities(:sergey), places(:orsha)
    assert_equal 3, stm.length, "Wrong storehouse length"
    stm.each do |entry|
      if entry.product.id == Product.find_by_resource_tag("roof").id
        assert_equal 238, entry.amount, "Wrong storehouse amount"
      elsif entry.product.id == Product.find_by_resource_tag("shovel").id
        if entry.owner.id == entities(:jdow).id
          assert_equal 110, entry.amount, "Wrong storehouse amount"
        elsif entry.owner.id == Entity.find_by_tag("StorehouseRelease").id
          assert_equal 20, entry.amount, "Wrong storehouse amount"
        else
          assert false, "Unknown entity"
        end
      else
        assert false, "Wrong storehouse entry"
      end
    end

    stm = Storehouse.taskmaster entities(:jdow), places(:orsha)
    assert_equal 2, stm.length, "Wrong storehouse length"
    stm.each do |entry|
      if entry.product.id == Product.find_by_resource_tag("roof").id
        assert_equal 238, entry.amount, "Wrong storehouse amount"
      elsif entry.product.id == Product.find_by_resource_tag("shovel").id
        assert_equal 110, entry.amount, "Wrong storehouse amount"
      else
        assert false, "Wrong storehouse entry"
      end
    end
  end

  test "check storehouse state after return" do
    storekeeper = Entity.new(:tag => "Storekeeper")
    assert storekeeper.save, "Entity not saved"
    warehouse = Place.new(:tag => "Some warehouse")
    assert warehouse.save, "Entity not saved"
    taskmaster = Entity.new :tag => "Taskmaster"
    assert taskmaster.save, "Entity is not saved"

    wb = Waybill.new(:owner => storekeeper,
      :document_id => "12834",
      :place => warehouse,
      :from => "Organization Store",
      :created => DateTime.civil(2011, 4, 2, 12, 0, 0))
    wb.add_resource assets(:sonyvaio).tag, "th", 100
    assert wb.save, "Waybill is not saved"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 3, 12, 0, 0),
      :owner => storekeeper,
      :place => warehouse,
      :to => taskmaster)
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 30
    assert sr.save, "StorehouseRelease not saved"
    assert sr.apply, "Storehouse release is not applied"

    sh = Storehouse.new storekeeper, warehouse
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 70, sh[0].amount, "Wrong storehouse amount"
    assert_equal 70, sh[0].real_amount, "Wrong storehouse amount"

    sh = Storehouse.taskmasters storekeeper, warehouse
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 30, sh[0].amount, "Wrong storehouse amount"

    sh = Storehouse.taskmaster taskmaster, warehouse
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 30, sh[0].amount, "Wrong storehouse amount"

    sr = StorehouseReturn.new :created_at => DateTime.civil(2011, 4, 4, 12, 0, 0),
        :from => taskmaster,
        :to => storekeeper,
        :place => warehouse
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 10
    assert sr.save, "StorehouseReturn not saved"

    sh = Storehouse.new storekeeper, warehouse
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 80, sh[0].amount, "Wrong storehouse amount"
    assert_equal 80, sh[0].real_amount, "Wrong storehouse amount"

    sh = Storehouse.taskmasters storekeeper, warehouse
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 20, sh[0].amount, "Wrong storehouse amount"

    sh = Storehouse.taskmaster taskmaster, warehouse
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 20, sh[0].amount, "Wrong storehouse amount"

    sr = StorehouseRelease.new(:created => DateTime.civil(2011, 4, 5, 12, 0, 0),
      :owner => storekeeper,
      :place => warehouse,
      :to => taskmaster)
    sr.add_resource Product.find_by_resource_id(assets(:sonyvaio)), 30
    assert sr.save, "StorehouseRelease not saved"

    sh = Storehouse.new storekeeper, warehouse
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 50, sh[0].amount, "Wrong storehouse amount"
    assert_equal 80, sh[0].real_amount, "Wrong storehouse amount"

    sh = Storehouse.taskmasters storekeeper, warehouse
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 20, sh[0].amount, "Wrong storehouse amount"

    sh = Storehouse.taskmaster taskmaster, warehouse
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 20, sh[0].amount, "Wrong storehouse amount"
  end

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

    sh = Storehouse.new storekeeper, warehouse
    assert_equal 2, sh.length, "Wrong storehouse length"
    assert_equal 100, sh[0].amount, "Wrong storehouse amount"
    assert_equal 100, sh[0].real_amount, "Wrong storehouse amount"
    assert_equal assets(:sonyvaio).tag, sh[0].product.resource.real_tag, "Wrong resource tag"
    assert_equal 150, sh[1].amount, "Wrong storehouse amount"
    assert_equal 150, sh[1].real_amount, "Wrong storehouse amount"
    assert_equal "sony VAI O", sh[1].product.resource.real_tag, "Wrong resource tag"

    a = asset_reals(:notebooksv)
    a.assets << Asset.find_by_tag("sony VAI O")
    a.assets << assets(:sonyvaio)

    sh = Storehouse.new storekeeper, warehouse
    assert_equal 1, sh.length, "Wrong storehouse length"
    assert_equal 250, sh[0].amount, "Wrong storehouse amount"
    assert_equal 250, sh[0].real_amount, "Wrong storehouse amount"
    assert_equal asset_reals(:notebooksv).tag, sh[0].product.resource.real_tag, "Wrong resource tag"

    wb = Waybill.new(:owner => storekeeper,
      :document_id => "123456",
      :place => warehouse,
      :from => "Organization Store 3",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb.add_resource "sony 3D", "th", 50
    assert wb.save, "Waybill is not saved"

    sh = Storehouse.new storekeeper, warehouse
    assert_equal 2, sh.length, "Wrong storehouse length"
    sh.each do |entry|
      if entry.owner.id == storekeeper.id
        if asset_reals(:notebooksv).tag == entry.product.resource.real_tag
          assert_equal 250, entry.amount, "Wrong storehouse amount"
          assert_equal 250, entry.real_amount, "Wrong storehouse amount"
        elsif "sony 3D" == entry.product.resource.real_tag
          assert_equal 50, entry.amount, "Wrong storehouse amount"
          assert_equal 50, entry.real_amount, "Wrong storehouse amount"
        else
          assert false, "Unknown resource"
        end
      else
        assert false, "Unknown owner id"
      end
    end

    sh = Storehouse.new
    assert_equal 2, sh.length, "Wrong storehouse length"
    sh.each do |entry|
      if entry.owner.id == storekeeper.id
        if asset_reals(:notebooksv).tag == entry.product.resource.real_tag
          assert_equal 250, entry.amount, "Wrong storehouse amount"
          assert_equal 250, entry.real_amount, "Wrong storehouse amount"
        elsif "sony 3D" == entry.product.resource.real_tag
          assert_equal 50, entry.amount, "Wrong storehouse amount"
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

    sh = Storehouse.new
    assert_equal 3, sh.length, "Wrong storehouse length"
    sh.each do |entry|
      if entry.owner.id == storekeeper.id
        if asset_reals(:notebooksv).tag == entry.product.resource.real_tag
          assert_equal 250, entry.amount, "Wrong storehouse amount"
          assert_equal 250, entry.real_amount, "Wrong storehouse amount"
        elsif "sony 3D" == entry.product.resource.real_tag
          assert_equal 50, entry.amount, "Wrong storehouse amount"
          assert_equal 50, entry.real_amount, "Wrong storehouse amount"
        else
          assert false, "Unknown resource"
        end
      elsif entry.owner.id == storekeeper2.id
        if asset_reals(:notebooksv).tag == entry.product.resource.real_tag
          assert_equal 100, entry.amount, "Wrong storehouse amount"
          assert_equal 100, entry.real_amount, "Wrong storehouse amount"
        else
          assert false, "Unknown resource"
        end
      else
        assert false, "Unknown owner id"
      end
    end
  end

  test "group storehouses entry by resource and check waybills" do
    storekeeper = Entity.new(:tag => "Storekeeper")
    assert storekeeper.save, "Entity not saved"
    warehouse = Place.new(:tag => "Some warehouse")
    assert warehouse.save, "Entity not saved"

    wb1 = Waybill.new(:owner => storekeeper,
      :document_id => "12834",
      :place => warehouse,
      :from => "Organization Store",
      :created => DateTime.civil(2011, 4, 2, 12, 0, 0))
    wb1.add_resource assets(:sonyvaio).tag, "th", 100
    assert wb1.save, "Waybill is not saved"

    wb2 = Waybill.new(:owner => storekeeper,
      :document_id => "12345",
      :place => warehouse,
      :from => "Organization Store 2",
      :created => DateTime.civil(2011, 4, 2, 12, 0, 0))
    wb2.add_resource "sony VAI O", "th", 150
    assert wb2.save, "Waybill is not saved"

    a = asset_reals(:notebooksv)
    a.assets << Asset.find_by_tag("sony VAI O")
    a.assets << assets(:sonyvaio)

    wb3 = Waybill.new(:owner => storekeeper,
      :document_id => "123456",
      :place => warehouse,
      :from => "Organization Store 3",
      :created => DateTime.civil(2011, 4, 5, 12, 0, 0))
    wb3.add_resource "sony 3D", "th", 50
    assert wb3.save, "Waybill is not saved"

    sh = Storehouse.new storekeeper, warehouse
    assert_equal 2, sh.length, "Wrong entries count"
    wbs = sh.waybills
    assert_equal 3, wbs.length, "Wrong waybills count"
    wbs.each do |item|
      assert item.instance_of?(StorehouseWaybill), "Unknown instance"
      assert !item.resources.nil?, "Wrong resources"
      if item.waybill.id == wb1.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.real_tag == asset_reals(:notebooksv).tag
            assert_equal 100, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      elsif item.waybill.id == wb2.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.real_tag == asset_reals(:notebooksv).tag
            assert_equal 150, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      elsif item.waybill.id == wb3.id
        assert_equal 1, item.resources.length, "Wrong resources count"
        item.resources.each do |sw|
          if sw.product.resource.tag == "sony 3D"
            assert_equal 50, sw.amount, "Wrong resource amount"
          else
            assert false, "Wrong resource"
          end
        end
      else
        assert false, "Unknown waybill"
      end
    end
  end
end
