class ChartsController < ApplicationController

  def index
    @chart = Chart.new
  end

  def create
    @chart = Chart.new(params[:chart])
    @chart.save
  end

end
