class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :summary
      t.integer :status
      t.references :reporter
      t.references :assignee
    end

    add_index :tasks, :summary, :unique => true
  end

  def self.down
    remove_index :tasks, :summary
    drop_table :tasks
  end
end
