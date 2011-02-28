require 'test_helper'

class EntityTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "entity should save" do
    e = Entity.new
    assert !e.save, "Entity without tag saved"
    e.tag = entities(:abstract).tag
    assert !e.save, "Entity with repeating tag saved"
    assert_equal 5, Entity.all.count
  end
end
