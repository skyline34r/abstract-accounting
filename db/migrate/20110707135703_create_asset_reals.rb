class CreateAssetReals < ActiveRecord::Migration
  def self.up
    create_table :asset_reals do |t|
      t.string :tag
    end
    add_index :asset_reals, :tag, :unique => true
  end

  def self.down
    drop_table :asset_reals
  end
end
