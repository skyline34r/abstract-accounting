class RolesController < ApplicationController
  before_filter :set_current_user

  def index
    session[:res_type] = ''
    @project_pages = project_pages
  end

  def view
    @columns = ['name', 'pages']

    @role = Role.all
    if params[:_search]
      args = Hash.new
      if !params[:name].nil?
        args['name'] = {:like => params[:name]}
      end
      @role = @role.where args
    end
    objects_order_by_from_params @role, params
    if session[:role_id].nil?
      @roles = @role.paginate(
        :page     => params[:page],
        :per_page => params[:rows])
    else
      page = 1
      begin
        @roles = @role.paginate(
          :page     => page,
          :per_page => params[:rows])
        page += 1
      end while @roles.where(:id => session[:role_id]).first.nil?
      session[:role_id] = nil
    end
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@roles, @columns, :id_column => 'id')
    end
  end
  
  def new
    @project_pages = project_pages
    @role = Role.new
  end

  def edit
    @project_pages = project_pages
    @role = Role.find(params[:id])
  end

  def create
    @role = Role.new(params[:role])
    if !@role.save
      render :action => "new"
    end
    session[:role_id] = @role.id
  end

  def update
    @role = Role.find(params[:id])
    if !@role.update_attributes(params[:role])
      render :action => "edit"
    end
    session[:role_id] = @role.id
  end

  def project_pages
    [ "Place", "Entity" , "Asset", "Money", "Deal", "Fact", "Chart", "Quote",
      "Balance", "GeneralLedger", "Transcript", "Storehouse", "Taskmaster",
      "StorehouseReturn"]
  end

end
