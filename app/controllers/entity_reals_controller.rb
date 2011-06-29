class EntityRealsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
  end

  def view
    @columns = ['tag']
    @entity_reals = EntityReal.all
    if params[:_search]
      args = Hash.new
      if !params[:tag].nil?
        args['tag'] = {:like => params[:tag]}
      end
      @entity_reals = @entity_reals.where args
    end
    objects_order_by_from_params @entity_reals, params
    @entity_reals = @entity_reals.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
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
    if !@entity_real.save
      render :action => "new"
    end
  end

  def update
    @entity_real = EntityReal.find(params[:id])
    unless @entity_real.update_attributes(params[:entity_real])
      render :action => "edit"
    end
  end

end
