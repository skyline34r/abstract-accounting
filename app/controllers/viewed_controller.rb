# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class ViewedController < ApplicationController
  def view
    if Viewed.find_by_user_id_and_item_id_and_item_type(params[:user_id],
                                                        params[:item_id],
                                                        params[:item_type]).nil?
      Viewed.create(user_id: params[:user_id],
                    item_id: params[:item_id],
                    item_type: params[:item_type])
      render :json => { result: true}
    else
      render :json => { result: false}
    end
  end
end
