class AddDisableColumnsToWaybills < ActiveRecord::Migration
  def self.up
    add_column :waybills, :disable_deal_id, :integer
    add_column :waybills, :comment, :string
  end

  def self.down
    remove_column :waybills, :comment
    remove_column :waybills, :disable_deal_id
  end
end
