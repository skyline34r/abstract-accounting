class CreateRules < ActiveRecord::Migration
  def self.up
    create_table :rules do |t|
      t.references :deal
      t.boolean :fact_side
      t.boolean :change_side
      t.float :rate
      t.string :tag
      t.references :from
      t.references :to
    end
  end

  def self.down
    drop_table :rules
  end
end
