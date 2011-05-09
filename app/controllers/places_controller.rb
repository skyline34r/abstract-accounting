class PlacesController < ApplicationController
  def index
    session[:res_type] = ''
  end

  def new
    @place = Place.new
  end

  def edit
    @place = Place.find(params[:id])
  end

  def create
    @place = Place.new(params[:place])
    if !@place.save
      render :action => "new"
    end
  end
end
