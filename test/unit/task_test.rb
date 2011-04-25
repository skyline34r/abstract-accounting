require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "all necessary data must exist" do
    u = User.new(:email => "test@mail.com",
             :password => "sasasasa",
             :password_confirmation => "sasasasa",
             :username => "test_root")
    assert u.save, "user is not saved"
    assert Task.new(:summary => "Summary",
      :status => 1, :reporter => u, :assignee => u).valid?,
      "Wrong task valid state"
    assert Task.new(:status => 1, :reporter => u, :assignee => u).invalid?,
      "Wrong task invalid state"
    assert Task.new(:summary => "Summary", :reporter => u, :assignee => u).invalid?,
      "Wrong task invalid state"
    assert Task.new(:summary => "Summary",
      :status => 1, :assignee => u).invalid?,
      "Wrong task invalid state"
    assert Task.new(:summary => "Summary",
      :status => 1, :reporter => u).invalid?,
      "Wrong task invalid state"
  end
end
