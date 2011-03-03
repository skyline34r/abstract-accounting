class ChartsController < ApplicationController

  def index
    session[:res_type] = 'money'
    @count = Chart.all
    @chart = Chart.new
  end

  def create
    @chart = Chart.new(params[:chart])
    @chart.save
  end

end
