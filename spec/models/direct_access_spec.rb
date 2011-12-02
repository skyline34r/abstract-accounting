# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe DirectAccess do
  it "should have next behaviour" do
    Factory(:direct_access)
    should validate_presence_of :user_id
    should validate_presence_of :item_id
    should validate_presence_of :item_type
    should validate_uniqueness_of(:item_type).scoped_to(:user_id, :item_id)
    should belong_to :user
    should belong_to :item
    should have_many DirectAccess.versions_association_name
  end
end
