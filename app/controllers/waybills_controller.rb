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
    @waybill.save
    render :action => 'new'
  end
end
