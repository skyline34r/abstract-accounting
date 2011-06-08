require 'resource'

class ChartsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
    session[:res_type] = 'money'
    if(Chart.all.count != 0) then
      @money_tag = Money.where(:id => Chart.all.first.currency_id).first.alpha_code
    end
    @chart = Chart.new
  end

  def create
    @chart = Chart.new(params[:chart])
    if !@chart.save
      render :action => "index"
    end
  end

end
