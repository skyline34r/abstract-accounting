class AddPlaceColumnToStorehouseRelease < ActiveRecord::Migration
  def self.up
    add_column :storehouse_releases, :place_id, :integer
  end

  def self.down
    remove_column :storehouse_releases, :place_id
  end
end
