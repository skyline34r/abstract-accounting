class AddRealIdToAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :real_id, :integer
  end

  def self.down
    remove_column :assets, :real_id
  end
end
