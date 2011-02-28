class CreateTxns < ActiveRecord::Migration
  def self.up
    create_table :txns do |t|
      t.references :fact
      t.float :value
      t.integer :status
      t.float :earnings
    end
    add_index :txns, :fact_id, :unique => true
  end

  def self.down
    drop_table :txns
  end
end
