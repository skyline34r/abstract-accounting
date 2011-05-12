require 'storehouse.rb'

class StorehousesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource

  def index
    session[:res_type] = ''
  end

  def view
    @columns = ['product.resource.tag', 'amount', 'place.tag']
    @storehouse = Storehouse.new(current_user.entity,
                                 current_user.place).paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@storehouse, @columns, :id_column => 'product.resource.id')
    end
  end

  def new
    session[:res_type] = ''
  end

  def create
    @release = StorehouseRelease.new(:created => DateTime.now,
                                     :owner => current_user.entity,
                                     :place => current_user.place)
    if params[:to] != nil and params[:to].length > 0 then
      @release.to = params[:to]
    end
    if params[:resource_id] != nil then
      for i in 0..params[:resource_id].length-1
        @release.add_resource(Product.find_by_resource_id(params[:resource_id][i]),
                                                          params[:release_amount][i].to_f)
      end
    end
    if !@release.save then
      render :action => 'new'
    end
  end

  def releases
    session[:res_type] = ''
  end

  def list
    @columns = ['created', 'owner.tag', 'to.tag', 'place.tag']
    @releases = StorehouseRelease.inwork.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@releases, @columns, :id_column => 'id')
    end
  end

  def show
    release = StorehouseRelease.find(params[:id])
    @place = release.place.tag
    @owner = release.owner.tag
    @date = release.created.strftime("%x")
    @to = release.to.tag
  end

  def view_release
    @columns = ['product.resource.tag', 'amount']
    release = StorehouseRelease.find(params[:id])
    @resources = release.resources.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@resources, @columns)
    end
  end

  def cancel
    StorehouseRelease.find(params[:id]).cancel
    render :action => 'releases'
  end

  def apply
    StorehouseRelease.find(params[:id]).apply
    render :action => 'releases'
  end
end
