class RenameChartColumn < ActiveRecord::Migration
  def self.up
    change_table :charts do |t|
      t.rename :money_id, :currency_id
    end
  end

  def self.down
    change_table :charts do |t|
      t.rename :currency_id, :money_id
    end
  end
end
