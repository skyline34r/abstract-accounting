class AddRealIdColumnToEntity < ActiveRecord::Migration
  def self.up
    add_column :entities, :real_id, :integer
  end

  def self.down
    remove_column :entities, :real_id
  end
end
