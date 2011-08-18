require 'test_helper'

class AssetRealTest < ActiveSupport::TestCase
  test "asset real should save" do
    e = AssetReal.new
    assert !e.save, "Asset real without tag saved"
    e.tag = asset_reals(:abstractasi).tag
    assert !e.save, "Asset real with repeating tag saved"
    assert_equal 2, AssetReal.all.count
  end
end
