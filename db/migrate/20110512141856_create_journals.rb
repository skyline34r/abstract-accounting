class CreateJournals < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
      t.references :fact
      t.datetime :created_at
      t.references :created_by
    end
    add_index :journals, :fact_id, :unique => true
  end

  def self.down
    remove_index :journals, :fact_id
    drop_table :journals
  end
end
