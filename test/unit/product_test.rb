require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "validation" do
    assert Product.new.invalid?, "Empty product valid"
    assert Product.new(:unit => "th").invalid?, "Wrong product valid"
    assert Product.new(:resource => assets(:sonyvaio)).invalid?, "Wrong product valid"
    assert Product.new(:resource => assets(:sonyvaio),
      :unit => "th").invalid?, "Wrong product valid"
    assert Asset.new(:tag => "roof").save, "Asset is not saved"
    assert Product.new(:resource => Asset.find_by_tag("roof"),
      :unit => "th").valid?, "Product invalid"

    assert Product.new(:resource => Asset.find_by_tag("roof"),
      :unit => "th").save, "Product not saved"
    Product.all.each do |item|
      assert !item.resource.nil?, "Asset is not valid"
    end
  end

  test "assign asset as text" do
    assert Asset.new(:tag => "Some asset").save, "asset is not saved"
    p = Product.new :unit => "th"
    p.resource = Asset.find_by_tag "Some asset"
    assert p.save, "Product not saved"

    assert Asset.new(:tag => "Some asset 2").save, "asset is not saved"
    p = Product.new :unit => "th"
    p.resource = "Some asset 2"
    assert_equal Asset.find_by_tag("Some asset 2"), p.resource, "Wrong product asset"
    assert p.save, "Product is not saved"

    assert Asset.new(:tag => "Some asset 3").save, "asset is not saved"
    p = Product.new :unit => "th"
    p.resource = "Some ASSET 3"
    assert_equal Asset.find_by_tag("Some asset 3"), p.resource, "Wrong product asset"
    assert p.save, "Product is not saved"

    p = Product.new :unit => "th"
    p.resource = "Some asset 4"
    assert p.resource.instance_of?(Asset), "Wrong asset type"
    assert p.save, "Product is not saved"
    assert_equal Asset.find_by_tag("Some asset 4"), p.resource, "Wrong product asset"
  end

  test "find product by resource tag" do
    assert Product.new(:resource => "roof",
      :unit => "m2").save, "product is not saved"
    assert Product.new(:resource => "dalle",
      :unit => "m2").save, "product is not saved"
    assert !Product.find_by_resource_tag("roof").nil?, "Wrong product find"
    assert !Product.find_by_resource_tag("DAlle").nil?, "Wrong product find"
    assert !Product.find_by_resource_tag("dalle").new_record?, "Wrong product find"
    assert Product.find_by_resource_tag("dalle 2").nil?, "Wrong product find"
  end
end
