class AddDocumentIdColumnToWaybills < ActiveRecord::Migration
  def self.up
    add_column :waybills, :document_id, :string
  end

  def self.down
    remove_column :waybills, :document_id
  end
end
