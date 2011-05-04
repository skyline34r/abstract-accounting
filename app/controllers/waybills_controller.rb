class WaybillsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def new
    @waybill = Waybill.new
  end

  def create
    entry = Array.new(params[:entry_resource].length);
    for i in 0..params[:entry_resource].length-1
      entry[i] = WaybillEntry.new(:unit => params[:entry_unit][i],
                                  :amount => params[:entry_amount][i])
      entry[i].assign_resource_text(params[:entry_resource][i])
    end
    @waybill = Waybill.new(params[:waybill])
    @waybill.waybill_entries = entry
    if params[:organization_text] != '' then
      @waybill.assign_organization_text(params[:organization_text])
    end
    if @waybill.save then
      render :action => 'new'
    else
      #render :js => 'alert("jkj");'
      puts @waybill.errors
    end
  end

  def view
    @columns = ['date', 'organization.tag', 'owner.tag', 'vatin']
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
