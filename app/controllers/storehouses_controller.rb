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
      render :json => abstract_json_for_jqgrid(@storehouse, @columns, :id_column => 'resource.id')
    end
  end

  def new
    session[:res_type] = ''
  end

  def create
    @release = StorehouseRelease.new(:created => DateTime.now,
                                     :owner => current_user.entity)
    if params[:to] != nil and params[:to].length > 0 then
      @release.to = params[:to]
    end
    if params[:resource_id] != nil then
      for i in 0..params[:resource_id].length-1
        @release.add_resource(Asset.where(:id => params[:resource_id][i]).first,
                                          params[:release_amount][i].to_f)
      end
    end
    if @release.save then
      render :action => 'index'
    else
      render :action => 'new'
    end
  end

  def releases
    session[:res_type] = ''
  end

  def list
    @columns = ['created', 'owner.tag', 'to.tag']
    @releases = StorehouseRelease.inwork.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@releases, @columns)
    end
  end

  def show
    release = StorehouseRelease.find(params[:id])
    @owner = release.owner.tag
    @date = release.created
    @to = release.to.tag
  end

  def view_release
    @columns = ['resource.tag', 'amount']
    release = StorehouseRelease.find(params[:id])
    @resources = release.resources.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@resources, @columns)
    end
  end
end
