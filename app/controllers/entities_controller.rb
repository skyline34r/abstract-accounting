class EntitiesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
    session[:res_type] = ''
  end

  def view
    @columns = ['tag']
    if !params[:columns].nil? and params[:columns] == 'full'
      @columns << 'real.tag'
    end
    base_entities = nil
    real_included = false
    unless params[:sidx].nil?
      if params[:sidx] == 'tag'
        base_entities = Entity.order('entities.' + params[:sidx] + " " + params[:sord].upcase)
      elsif params[:sidx] == 'real'
        real_included = true
        base_entities = Entity.includes(:real).
            order('entity_reals.tag ' + params[:sord].upcase)
      end
    end
    unless params[:_search].nil?
      base_entities = (base_entities.nil? ? Entity.where('lower(entities.tag) LIKE ?', "%#{params[:tag].downcase}%") :
          base_entities.where('lower(entities.tag) LIKE ?', "%#{params[:tag].downcase}%")) unless params[:tag].nil?
      unless params[:real].nil?
        base_entities = (base_entities.nil? ? Entity.includes(:real) :
          base_entities.includes(:real)) unless real_included
        base_entities = base_entities.where('lower(entity_reals.tag) LIKE ?', "%#{params[:real].downcase}%")
      end
    end
    base_entities = (base_entities.nil? ? Entity.all : base_entities.all) if params[:filter].nil?
    base_entities = (base_entities.nil? ? Entity.where('real_id is NULL') :
        base_entities.where('real_id is NULL')) if params[:filter] == "unassigned"

    if session[:entity_id].nil?
      @entities = base_entities.paginate(
        :page     => params[:page],
        :per_page => params[:rows])
    else
      page = 1
      begin
        @entities = base_entities.paginate(
          :page     => page,
          :per_page => params[:rows])
        page += 1
      end while @entities.where(:id => session[:entity_id]).first.nil?
      session[:entity_id] = nil
    end
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@entities, @columns, :id_column => 'id')
    end
  end

  def select
    @with_check = false
    @entities = nil
    unless params[:real_id].nil?
      @list_url = entities_surrogates_url :real_id => params[:real_id]
      if params[:type] == "edit"
        @with_check = true
        @list_url += "?filter=unassigned"
        @entities = Entity.where('real_id = ?', params[:real_id])
      end
    else
      @list_url = view_entities_url + "?filter=unassigned"
      @with_check = true
    end
  end

  def surrogates
    @columns = ['tag', 'real.nil?']
    base_entities = nil
    unless params[:sidx].nil?
      base_entities = Entity.order(params[:sidx] + " " + params[:sord].upcase)
    end
    unless params[:_search].nil? or params[:tag].nil?
      base_entities = (base_entities.nil? ? Entity.where('lower(tag) LIKE ?', "%#{params[:tag].downcase}%") :
          base_entities.where('lower(tag) LIKE ?', "%#{params[:tag].downcase}%"))
    end
    @entities = (base_entities.nil? ?
        Entity.find_all_by_real_id(params[:real_id]) :
        base_entities.find_all_by_real_id(params[:real_id])) if params[:filter].nil?
    @entities = (base_entities.nil? ?
        Entity.where('real_id is NULL') :
        base_entities.where('real_id is NULL')) if params[:filter] == "unassigned"
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
    session[:entity_id] = @entity.id
  end

  def update
    @entity = Entity.find(params[:id])
    if !@entity.update_attributes(params[:entity])
      render :action => "edit"
    end
    session[:entity_id] = @entity.id
  end
  
end
