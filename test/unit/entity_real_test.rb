require 'test_helper'

class EntityRealTest < ActiveSupport::TestCase
  test "entity real should save" do
    e = EntityReal.new
    assert !e.save, "Entity real without tag saved"
    e.tag = entity_reals(:aa).tag
    assert !e.save, "Entity real with repeating tag saved"
    assert_equal 2, EntityReal.all.count
  end
end
