class PlacesController < ApplicationController
  def index
    session[:res_type] = ''
  end

  def new
    @place = Place.new
  end
end
