class AddIsOffBalanceToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :isOffBalance, :boolean, :default => false
  end

  def self.down
    remove_column :deals, :isOffBalance
  end
end
