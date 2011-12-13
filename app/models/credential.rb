# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Credential < ActiveRecord::Base
  has_paper_trail
  serialize :actions

  validates_presence_of :user_id
  validates_uniqueness_of :document_type, :scope =>[ :user_id, :place_id, :work_id ]
  belongs_to :user
  belongs_to :place
  belongs_to :work
end
