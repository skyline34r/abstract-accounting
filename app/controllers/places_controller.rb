class PlacesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

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
    session[:place_id] = @place.id
  end

  def update
    @place = Place.find(params[:id])
    if !@place.update_attributes(params[:place])
      render :action => "edit"
    end
    session[:place_id] = @place.id
  end

  def view
    @columns = ['tag']

    @place = Place.all
    if params[:_search]
      args = Hash.new
      if !params[:tag].nil?
        args['tag'] = {:like => params[:tag]}
      end
      @place = @place.where args
    end
    objects_order_by_from_params @place, params
    if session[:place_id].nil?
      @places = @place.paginate(
        :page     => params[:page],
        :per_page => params[:rows])
    else
      page = 1
      begin
        @places = @place.paginate(
          :page     => page,
          :per_page => params[:rows])
        page += 1
      end while @places.where(:id => session[:place_id]).first.nil?
      session[:place_id] = nil
    end
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@places, @columns, :id_column => 'id')
    end
  end

end
