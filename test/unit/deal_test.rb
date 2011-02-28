require 'test_helper'

class DealTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "Deal should be stored" do
    d = Deal.new
    assert !d.save, "Empty deal saved"

    deal_entity = entities(:sergey)
    deal_take = money(:rub)
    deal_give = assets(:aasiishare)
    deal_tag = deals(:equityshare1).tag
    deal_rate = deals(:equityshare1).rate

    d = Deal.new
    d.tag = deal_tag
    d.rate = deal_rate
    d.entity = deal_entity
    d.give = deal_give
    d.take = deal_take
    assert_raise ActiveRecord::RecordNotUnique do
      !d.save
    end

    d = deals(:equityshare1)
    assert_equal d, deal_entity.deals.where(:tag => deal_tag).first,
      "Entity deal is not equal to equityshare1"
    assert_equal d, deal_take.deal_takes.where(:tag => deal_tag).first,
      "Take resource not contain equityshare1"
    assert_equal d, deal_give.deal_gives.where(:tag => deal_tag).first,
      "Give resource not contain equityshare1"

    assert_equal 7, Deal.all.count, "Count of deals is not equal to 7"
  end
end
