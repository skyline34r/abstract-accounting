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

  test "entity real saved for entity" do
    e = entities(:abstract)
    e.real = entity_reals(:aa)
    assert e.valid?, "Valid entity with real"
    assert e.save, "Entity is not updated"

    e = Entity.find_by_tag "abstract"
    assert_equal entity_reals(:aa).id, e.real_id, "Invalid real id"
    assert_equal 1, entity_reals(:aa).entities.length, "Invalid entities length"

    e = Entity.new :tag => "astract accounting", :real => entity_reals(:aa)
    assert e.save, "Entity is not saved"
    assert_equal 2, entity_reals(:aa).entities(true).length, "Invalid entities length"
  end
end
