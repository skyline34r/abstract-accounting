class EntitiesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
    session[:res_type] = ''
  end

  def view
    @columns = ['tag']

    @entities = Entity.all
    if params[:_search]
      args = Hash.new
      if !params[:tag].nil?
        args['tag'] = {:like => params[:tag]}
      end
      @entities = @entities.where args
    end
    objects_order_by_from_params @entities, params
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
