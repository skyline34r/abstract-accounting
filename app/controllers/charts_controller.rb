class ChartsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    session[:res_type] = 'money'
    @charts = Chart.all
    @chart = Chart.new
  end

  def create
    @chart = Chart.new(params[:chart])
    @chart.save
  end

end
