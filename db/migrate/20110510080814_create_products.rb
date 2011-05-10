class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :unit
      t.references :asset
    end
    add_index :products, :asset_id, :unique => true
  end

  def self.down
    remove_index :products, :asset_id
    drop_table :products
  end
end
