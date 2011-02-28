class CreateBalances < ActiveRecord::Migration
  def self.up
    create_table :balances do |t|
      t.references :deal
      t.string :side
      t.float :amount
      t.float :value
      t.datetime :start
      t.datetime :paid
    end
    add_index :balances, [:deal_id, :start], :unique => true
  end

  def self.down
    drop_table :balances
  end
end
