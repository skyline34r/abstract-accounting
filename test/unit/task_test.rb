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
      :status => Task::Unconfirmed, :reporter => u, :assignee => u).valid?,
      "Wrong task valid state"
    assert Task.new(:status => Task::Unconfirmed, :reporter => u,
      :assignee => u).invalid?,
      "Wrong task invalid state"
    assert Task.new(:summary => "Summary", :reporter => u, :assignee => u).invalid?,
      "Wrong task invalid state"
    assert Task.new(:summary => "Summary",
      :status => Task::Unconfirmed, :assignee => u).invalid?,
      "Wrong task invalid state"
    assert Task.new(:summary => "Summary",
      :status => Task::Unconfirmed, :reporter => u).invalid?,
      "Wrong task invalid state"
  end

  test "summary must be unique" do
    u = User.new(:email => "test@mail.com",
             :password => "sasasasa",
             :password_confirmation => "sasasasa",
             :username => "test_root")
    assert u.save, "user is not saved"
    assert Task.new(:summary => "Summary",
      :status => Task::Unconfirmed, :reporter => u, :assignee => u).save,
      "Task is not saved"
    assert Task.new(:summary => "Summary",
      :status => Task::Unconfirmed, :reporter => u, :assignee => u).invalid?,
      "Task is valid"
  end

  test "state must be in task enumerated states" do
    u = User.new(:email => "test@mail.com",
             :password => "sasasasa",
             :password_confirmation => "sasasasa",
             :username => "test_root")
    assert u.save, "user is not saved"
    assert Task.new(:summary => "Summary",
      :status => Task::Unconfirmed, :reporter => u, :assignee => u).valid?,
      "Task is invalid"
    assert Task.new(:summary => "Summary",
      :status => Task::Unassigned, :reporter => u, :assignee => u).valid?,
      "Task is invalid"
    assert Task.new(:summary => "Summary",
      :status => Task::InWork, :reporter => u, :assignee => u).valid?,
      "Task is invalid"
    assert Task.new(:summary => "Summary",
      :status => Task::Implemented, :reporter => u, :assignee => u).valid?,
      "Task is invalid"
    assert Task.new(:summary => "Summary",
      :status => Task::Closed, :reporter => u, :assignee => u).valid?,
      "Task is invalid"
    assert Task.new(:summary => "Summary",
      :status => 25, :reporter => u, :assignee => u).invalid?,
      "Task is valid"
  end
end
