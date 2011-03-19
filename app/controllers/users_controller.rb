class UsersController < ApplicationController
  def index
    session[:res_type] = ''
    @columns = ['email', 'role_ids', 'id']
    @users = User.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@users, @columns)
    end
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    if !@user.save
      render :action => "new"
    end
  end

  def update
    @user = User.find(params[:id])
    if !@user.update_attributes(params[:user])
      render :action => "edit"
    end
  end
end
