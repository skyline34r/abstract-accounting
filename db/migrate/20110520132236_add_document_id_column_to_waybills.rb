class AddDocumentIdColumnToWaybills < ActiveRecord::Migration
  def self.up
    add_column :waybills, :document_id, :string
    add_index :waybills, :document_id, :unique => true
  end

  def self.down
    remove_index :waybills, :document_id
    remove_column :waybills, :document_id
  end
end
