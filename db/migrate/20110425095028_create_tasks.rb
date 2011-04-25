class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :summary
      t.integer :status
      t.references :reporter
      t.references :assignee
    end
  end

  def self.down
    drop_table :tasks
  end
end
