class CreateIncomes < ActiveRecord::Migration
  def self.up
    create_table :incomes do |t|
      t.datetime :start
      t.string :side
      t.float :value
      t.datetime :paid
    end
    add_index :incomes, :start, :unique => true
  end

  def self.down
    drop_table :incomes
  end
end
