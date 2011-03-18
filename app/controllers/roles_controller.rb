class RolesController < ApplicationController

  def index
    session[:res_type] = ''
    @columns = ['name', 'id']
    @roles = Role.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@roles, @columns)
    end
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
