class CreateWaybillEntries < ActiveRecord::Migration
  def self.up
    create_table :waybill_entries do |t|
      t.references :waybill
      t.references :resource
      t.string :unit
      t.integer :amount
    end
  end

  def self.down
    drop_table :waybill_entries
  end
end
