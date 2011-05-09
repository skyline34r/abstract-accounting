class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.string :tag
    end
    add_index :places, :tag, :unique => true
  end

  def self.down
    drop_table :places
  end
end
