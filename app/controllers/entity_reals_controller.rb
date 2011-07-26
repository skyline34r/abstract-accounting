class EntityRealsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
  end

  def view
    @columns = ['tag', 'entities.empty?']
    base_reals = EntityReal.all
    if params[:_search]
      args = Hash.new
      if !params[:tag].nil?
        args['tag'] = {:like => params[:tag]}
      end
      base_reals = base_reals.where args
    end
    objects_order_by_from_params base_reals, params
    if session[:entity_id].nil?
      @entity_reals = base_reals.paginate(
        :page     => params[:page],
        :per_page => params[:rows])
    else
      page = 1
      begin
        @entity_reals = base_reals.paginate(
          :page     => page,
          :per_page => params[:rows])
        page += 1
      end while @entity_reals.where(:id => session[:entity_id]).empty?
      session[:entity_id] = nil
    end
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@entity_reals, @columns, :id_column => 'id')
    end
  end

  def new
    @entity_real = EntityReal.new
  end

  def edit
    @entity_real = EntityReal.find(params[:id])
  end

  def create
    @entity_real = EntityReal.new(params[:entity_real])
    @entity_real.entity_ids = params[:entities].collect { |id| id.to_i } if
        !params[:entities].nil? and !params[:entities].empty? and
            params[:entities][0] != "empty"
    unless @entity_real.save
      render :action => "new"
    end
    session[:entity_id] = @entity_real.id
  end

  def update
    @entity_real = EntityReal.find(params[:id])
    unless params[:entities].nil?
      if !params[:entities].empty? and params[:entities][0] != "empty"
        @entity_real.entity_ids = params[:entities].collect { |id| id.to_i }
      elsif params[:entities][0] == "empty"
        @entity_real.entities.clear
      end
    end
    unless @entity_real.save and @entity_real.update_attributes(params[:entity_real])
      render :action => "edit"
    end
    session[:entity_id] = @entity_real.id
  end

end
