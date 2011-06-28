class EntityRealController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
  end

  def view
    @entity_reals = EntityReal.all
  end

  def new
  end

  def edit
  end

  def create
    entity = EntityReal.new(params[:entity_real])
    if !entity.save
      render :action => "new"
    end
  end

  def update
    entity = EntityReal.find(params[:id])
    unless entity.update_attributes(params[:entity_real])
      render :action => "edit"
    end
  end

end
