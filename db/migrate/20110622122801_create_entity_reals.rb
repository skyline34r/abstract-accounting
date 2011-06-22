class CreateEntityReals < ActiveRecord::Migration
  def self.up
    create_table :entity_reals do |t|
      t.string :tag
    end
    add_index :entity_reals, :tag, :unique => true
  end

  def self.down
    drop_table :entity_reals
  end
end
