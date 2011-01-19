require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "account test" do
    assert_equal 0, Balance.all.count, "Balance count is not 0"
  end
end
