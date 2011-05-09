class PlacesController < ApplicationController
  def index
    session[:res_type] = ''
  end
end
