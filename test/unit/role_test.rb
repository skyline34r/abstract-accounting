require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test "role should save" do
    r = Role.new
    assert !r.save, "Empty role saved"
    r.name = "admin"
    assert r.save, "Role can't be saved"
    assert_equal 3, Role.all.count

    assert_equal "admin", Role.where(:id => r.id).first.name,
      "Role name is not equal to 'admin'"
  end

  test "role should save with permitted pages" do
    r = Role.new
    assert !r.save, "Empty role saved"
    r.name = "admin"
    r.pages = "Entity, Deal"
    assert r.save, "Role can't be saved"
    assert_equal 3, Role.all.count

    assert_equal "Entity, Deal", Role.where(:id => r.id).first.pages,
      "Role permitted pages is not equal to 'Entity, Deal'"
  end
end
