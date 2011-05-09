class AddPlaceColumnToWaybill < ActiveRecord::Migration
  def self.up
    add_column :waybills, :place_id, :integer
  end

  def self.down
    remove_column :waybills, :place_id
  end
end
