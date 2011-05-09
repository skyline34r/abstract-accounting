class PlacesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

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

  def view
    @columns = ['tag']
    @places = Place.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@places, @columns, :id_column => 'id')
    end
  end

end
