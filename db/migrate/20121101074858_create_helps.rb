class CreateHelps < ActiveRecord::Migration
  def change
    create_table :helps do |t|
      t.integer :user_id
      t.boolean :looked

      t.timestamps
    end
  end
end
