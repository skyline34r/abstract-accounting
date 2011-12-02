# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.references :user
      t.references :place
      t.references :work
      t.string :document_type
      t.string :actions
    end
    add_index :credentials, [:user_id, :place_id, :work_id, :document_type], :unique => true,
              :name => 'credentials_index'
  end
end
