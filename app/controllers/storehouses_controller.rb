require 'storehouse.rb'

class StorehousesController < ApplicationController

  def index
    session[:res_type] = ''
  end

  def view
    @columns = ['resource.tag', 'amount']
    @storehouse = StoreHouse.new(Entity.where(:id => params[:entity_id]).first)
    @storehouse = @storehouse.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@storehouse, @columns)
    end
  end

  def realise
    session[:res_type] = ''
  end
end
