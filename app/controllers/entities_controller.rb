class EntitiesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
    session[:res_type] = ''
  end

  def view
    @columns = ['tag']
    ordered_entities = nil
    unless params[:sidx].nil?
      ordered_entities = Entity.order(params[:sidx] + " " + params[:sord].upcase)
    end
    @entities = (ordered_entities.nil? ? Entity.all : ordered_entities.all) if params[:filter].nil?
    @entities = (ordered_entities.nil? ? Entity.where('real_id is NULL') :
        ordered_entities.where('real_id is NULL')) if params[:filter] == "unassigned"
    if params[:_search]
      args = Hash.new
      if !params[:tag].nil?
        args['tag'] = {:like => params[:tag]}
      end
      @entities = @entities.where args
    end
    @entities = @entities.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@entities, @columns, :id_column => 'id')
    end
  end

  def select
    @with_check = false
    unless params[:real_id].nil?
      @list_url = entities_surrogates_url :real_id => params[:real_id]
      if params[:type] == "edit"
        @with_check = true
        @list_url += "?filter=unassigned"
      end
    else
      @list_url = view_entities_url + "?filter=unassigned"
      @with_check = true
    end
  end

  def surrogates
    @columns = ['tag', 'real.nil?']
    ordered_entities = nil
    unless params[:sidx].nil?
      ordered_entities = Entity.order(params[:sidx] + " " + params[:sord].upcase)
    end
    @entities = (ordered_entities.nil? ?
        Entity.find_all_by_real_id(params[:real_id]) :
        ordered_entities.find_all_by_real_id(params[:real_id])) if params[:filter].nil?
    @entities = (ordered_entities.nil? ?
        Entity.where('real_id = ? OR real_id is NULL', params[:real_id]) :
        ordered_entities.where('real_id = ? OR real_id is NULL', params[:real_id])) if params[:filter] == "unassigned"
    if params[:_search]
      args = Hash.new
      if !params[:tag].nil?
        args['tag'] = {:like => params[:tag]}
      end
      @entities = @entities.where args
    end
    @entities = @entities.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@entities, @columns, :id_column => 'id')
    end
  end

  def new
    @entity = Entity.new
  end

  def edit
    @entity = Entity.find(params[:id])
  end

  def create
    @entity = Entity.new(params[:entity])
    if !@entity.save
      render :action => "new"
    end
  end

  def update
    @entity = Entity.find(params[:id])
    if !@entity.update_attributes(params[:entity])
      render :action => "edit"
    end
  end
  
end
