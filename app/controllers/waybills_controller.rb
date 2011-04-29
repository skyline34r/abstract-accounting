class WaybillsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

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
