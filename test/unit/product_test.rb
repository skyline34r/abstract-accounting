require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "validation" do
    assert Product.new.invalid?, "Empty product valid"
    assert Product.new(:unit => "th").invalid?, "Wrong product valid"
    assert Product.new(:asset => assets(:sonyvaio)).invalid?, "Wrong product valid"
    assert Product.new(:asset => assets(:sonyvaio),
      :unit => "th").invalid?, "Wrong product valid"
    assert Asset.new(:tag => "roof").save, "Asset is not saved"
    assert Product.new(:asset => Asset.find_by_tag("roof"),
      :unit => "th").valid?, "Product invalid"

    assert Product.new(:asset => Asset.find_by_tag("roof"),
      :unit => "th").save, "Product not saved"
    Product.all.each do |item|
      assert !item.asset.nil?, "Asset is not valid"
    end
  end
end
