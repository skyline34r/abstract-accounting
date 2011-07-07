require 'test_helper'

class ResourceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "asset should store" do
    a = Asset.new
    assert !a.save, "Asset with empty tag saved"
    a.tag = assets(:aasiishare).tag
    assert !a.save, "Asset with repeating tag saved"

    assert_equal 2, Asset.all.count, "Count of asset records is not equal to 1"
  end

  test "money should store" do
    m = Money.new
    m.num_code = 840
    m.alpha_code = money(:rub).alpha_code
    assert !m.save, "Money with repeating tag saved"
    m = Money.new
    assert !m.save, "Money with empty num_code and alpha_code saved"
    m.num_code = 643
    assert !m.save, "Money with empty alpha_code saved"
    m.alpha_code = "RUB"
    assert !m.save, "Copy of rub money is saved"
    assert_equal 2, Money.all.count, "Count of money record is not equal to 1"
  end

  test "asset real saved for asset" do
    a = assets(:aasiishare)
    a.real = asset_reals(:abstractasi)
    assert a.valid?, "Valid asset with real"
    assert a.save, "Asset is not updated"

    a = Asset.find_by_tag "AASI share"
    assert_equal asset_reals(:abstractasi).id, a.real_id, "Invalid real id"
    assert_equal 1, asset_reals(:abstractasi).assets.length, "Invalid assets length"

    a = Asset.new :tag => "AASI share 2", :real => asset_reals(:abstractasi)
    assert a.save, "Asset is not saved"
    assert_equal 2, asset_reals(:abstractasi).assets(true).length, "Invalid assets length"
  end
end
