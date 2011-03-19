ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  include Devise::TestHelpers
end

def sign_in_by_user
  u = User.new(:email => "user@mail.com",
               :password => "user_pass",
               :password_confirmation => "user_pass",
               :role_ids => [roles(:operator).id])
  assert u.save, "User can't be saved"
  sign_in u
end
