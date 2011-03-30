class RolesController < ApplicationController

  def index
    session[:res_type] = ''
    @project_pages = project_pages
  end

  def view
    @columns = ['name', 'pages']
    @roles = Role.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@roles, @columns, :id_column => 'id')
    end
  end
  
  def new
    @role = Role.new
  end

  def edit
    @role = Role.find(params[:id])
  end

  def create
    @role = Role.new(params[:role])
    if !@role.save
      render :action => "new"
    end
  end

  def update
    @role = Role.find(params[:id])
    if !@role.update_attributes(params[:role])
      render :action => "edit"
    end
  end

  def project_pages
    [ "Entity" , "Asset", "Money", "Deal", "Fact", "Chart", "Quote", "Balance",
      "GeneralLedger", "Transcript" ]
  end

end
