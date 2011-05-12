class CreateStorehouseReleases < ActiveRecord::Migration
  def self.up
    create_table :storehouse_releases do |t|
      t.references :owner
      t.references :place
      t.references :to
      t.references :deal
      t.datetime :created
      t.integer :state
    end
  end

  def self.down
    drop_table :storehouse_releases
  end
end
