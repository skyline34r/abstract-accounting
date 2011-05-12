class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :unit
      t.references :resource
    end
    add_index :products, :resource_id, :unique => true
  end

  def self.down
    remove_index :products, :resource_id
    drop_table :products
  end
end
