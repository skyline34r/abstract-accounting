class WaybillsController < ApplicationController
  def new
    @waybill = Waybill.new
  end

  def create
    @waybill = Waybill.new(params[:waybill])
    if params[:organization_text] != '' then
      @waybill.assign_organization_text(params[:organization_text])
    end
    @waybill.save
    render :action => 'new'
  end
end
