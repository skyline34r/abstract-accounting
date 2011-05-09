class WaybillsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    session[:res_type] = ''
  end

  def new
    @waybill = Waybill.new
  end

  def create
    @waybill = Waybill.new(params[:waybill])
    if current_user != nil && current_user.entity != nil then
      @waybill.owner = current_user.entity
    end
    if params[:entry_resource] != nil then
      entry = Array.new(params[:entry_resource].length);
      for i in 0..params[:entry_resource].length-1
        entry[i] = WaybillEntry.new(:unit => params[:entry_unit][i],
                                    :amount => params[:entry_amount][i])
        entry[i].assign_resource_text(params[:entry_resource][i])
      end
      @waybill.waybill_entries = entry
    end
    if params[:organization_text] != '' then
      @waybill.assign_organization_text(params[:organization_text])
    end
    if @waybill.save then
      render :action => 'index'
    else
      render :action => 'new'
    end
  end

  def view
    @columns = ['date', 'organization.tag', 'owner.tag', 'vatin', 'place.tag']
    @waybills = Waybill.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@waybills, @columns, :id_column => 'id')
    end
  end

  def show
    @columns = ['resource.tag', 'amount', 'unit']
    @entries = Waybill.find(params[:id]).waybill_entries
    @entries = @entries.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@entries, @columns, :id_column => 'id')
    end
  end
end
