require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "user should save" do
    u = User.new
    assert !u.save, "Empty user saved"
    u.email = "user@mail.com"
    u.password = "user_pass"
    u.password_confirmation = "user_pass"
    u.entity = entities(:abstract)
    assert u.save, "User can't be saved"
    assert_equal 1, User.all.count,
      "User can't be saved"
    assert_equal "user@mail.com", User.where(:id => u.id).first.email,
      "User email is not equal to 'user@mail.com'"
  end

  test "user should save with role" do
    u = User.new
    assert !u.save, "Empty user saved"
    u.email = "user@mail.com"
    u.password = "user_pass"
    u.password_confirmation = "user_pass"
    u.entity = entities(:abstract)
    u.roles << roles(:user)
    u.roles << roles(:operator)
    assert u.save, "User can't be saved"
    assert_equal 1, User.all.count,
      "User can't be saved"
    assert_equal "user@mail.com", User.where(:id => u.id).first.email,
      "User email is not equal to 'user@mail.com'"

    assert_equal 2, User.where(:id => u.id).first.roles.count
      "Rotes in user can't be added"
    assert_equal "User", User.where(:id => u.id).first.roles.first.name
      "Rotes in user can't be added"
  end

end
