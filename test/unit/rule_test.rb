require 'test_helper'

class RuleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "rule must be saved" do
    r = Rule.new :tag => "test rule", :deal => deals(:equityshare1),
      :rate => 1.0, :change_side => true, :fact_side => false,
      :from => deals(:equityshare2), :to => deals(:bankaccount)
    assert r.valid?, "Rule is not valid"
    assert r.save, "Rule is not saved"
  end
end
