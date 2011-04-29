class RemoveWaybillVatinIndex < ActiveRecord::Migration
  def self.up
    remove_index :waybills, :vatin
  end

  def self.down
    add_index(:waybills, :vatin, :unique => true)
  end
end
