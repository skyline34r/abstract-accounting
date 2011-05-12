class CreateWaybills < ActiveRecord::Migration
  def self.up
    create_table :waybills do |t|
      t.references :owner
      t.references :place
      t.references :from
      t.references :deal
      t.datetime :created
      t.string :vatin
    end
    add_index :waybills, :deal_id, :unique => true
  end

  def self.down
    remove_index :waybills, :deal_id
    drop_table :waybills
  end
end
