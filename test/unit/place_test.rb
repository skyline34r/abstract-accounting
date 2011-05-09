require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "validates" do
    assert Place.new(:tag => "Minsk").valid?, "Place is invalid"
    assert Place.new(:tag => "Moscow").save, "Place is not saved"
    assert Place.new(:tag => "Moscow").invalid?, "Place is valid"
  end
end
