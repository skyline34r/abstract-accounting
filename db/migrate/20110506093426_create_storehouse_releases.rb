class CreateStorehouseReleases < ActiveRecord::Migration
  def self.up
    create_table :storehouse_releases do |t|
      t.datetime :created
      t.references :deal
      t.integer :state
    end
  end

  def self.down
    drop_table :storehouse_releases
  end
end
