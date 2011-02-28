class CreateQuotes < ActiveRecord::Migration
  def self.up
    create_table :quotes do |t|
      t.references :money
      t.datetime :day
      t.float :rate
      t.float :diff
    end
    add_index :quotes, [:money_id, :day], :unique => true
  end

  def self.down
    drop_table :quotes
  end
end
