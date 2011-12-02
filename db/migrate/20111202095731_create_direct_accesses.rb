# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateDirectAccesses < ActiveRecord::Migration
  def change
    create_table :direct_accesses do |t|
      t.references :user
      t.references :item, :polymorphic => true
    end
    add_index :direct_accesses, [:user_id, :item_id, :item_type], :unique => true
  end
end
