class CreateWaybills < ActiveRecord::Migration
  def self.up
    create_table :waybills do |t|
      t.datetime :date
      t.references :owner
      t.references :organization
      t.string :vatin
    end
    add_index(:waybills, :vatin, :unique => true)
  end

  def self.down
    remove_index :waybills, :vatin
    drop_table :waybills
  end
end
