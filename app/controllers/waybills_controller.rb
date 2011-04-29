class WaybillsController < ApplicationController
  def new
    @waybill = Waybill.new
  end

  def create
    @waybill = Waybill.new(params[:waybill])
    @waybill.save
    render :action => "new"
  end
end
