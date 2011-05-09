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

  def update
    @place = Place.find(params[:id])
    if !@place.update_attributes(params[:place])
      render :action => "edit"
    end
  end

end
