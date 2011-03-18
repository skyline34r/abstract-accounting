require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "user should save" do
    u = User.new
    assert !u.save, "Empty user saved"
    u.email = "user@mail.com"
    u.password = "user_pass"
    u.password_confirmation = "user_pass"
    u.username = "user"
    assert u.save, "User can't be saved"
    assert_equal 1, User.all.count,
      "User can't be saved"
    assert_equal "user", User.where(:id => u.id).first.username,
      "User name is not equal to 'user'"
  end

  test "user should save with role" do
    u = User.new
    assert !u.save, "Empty user saved"
    u.email = "user@mail.com"
    u.password = "user_pass"
    u.password_confirmation = "user_pass"
    u.username = "user"
    u.roles << roles(:user)
    u.roles << roles(:operator)
    assert u.save, "User can't be saved"
    assert_equal 1, User.all.count,
      "User can't be saved"
    assert_equal "user", User.where(:id => u.id).first.username,
      "User name is not equal to 'user'"

    assert_equal 2, User.where(:id => u.id).first.roles.count
      "Rotes in user can't be added"
    assert_equal "user", User.where(:id => u.id).first.roles.first.name
      "Rotes in user can't be added"
  end

end
