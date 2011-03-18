class RolesController < ApplicationController

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      render :action => "new"
    end
  end

end
