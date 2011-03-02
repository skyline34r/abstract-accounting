class ChartsController < ApplicationController

  def index
    @count = Chart.all
    @chart = Chart.new
  end

  def create
    @chart = Chart.new(params[:chart])
    @chart.save
  end

end
