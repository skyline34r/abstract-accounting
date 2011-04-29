class WaybillsController < ApplicationController
  def new
    @waybill = Waybill.new
  end

  def create
    @waybill = Waybill.new(:date => params[:waybill][:date],
                           :owner => params[:waybill][:owner],
                           :organization => params[:waybill][:organization],
                           :vatin => params[:waybill][:vatin])
    if params[:waybill][:organization_text] != '' then
      @waybill.assign_organization_text(params[:waybill][:organization_text])
    end
    @waybill.save
    render :action => 'new'
  end
end
