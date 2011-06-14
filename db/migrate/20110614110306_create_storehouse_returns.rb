class CreateStorehouseReturns < ActiveRecord::Migration
  def self.up
    create_table :storehouse_returns do |t|
      t.references :from
      t.references :to
      t.references :place
      t.references :deal
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :storehouse_returns
  end
end
