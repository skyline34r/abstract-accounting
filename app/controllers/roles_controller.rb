class RolesController < ApplicationController

  def index
    session[:res_type] = ''
    @project_pages = project_pages
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
    @project_pages = project_pages
    @role = Role.new
  end

  def create
    @project_pages = project_pages
    @role = Role.new(params[:role])
    if !@role.save
      render :action => "new"
    end
  end

  def project_pages
    [ "Entity" , "Asset", "Money", "Deal", "Fact", "Chart", "Quote", "Balance",
      "GeneralLedger", "Transcript" ]
  end

end
