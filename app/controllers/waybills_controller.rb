class WaybillsController < ApplicationController
  def new
    @waybill = Waybill.new
  end
end
