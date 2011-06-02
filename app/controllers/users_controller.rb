class UsersController < ApplicationController
  before_filter :set_current_user

  def index
    session[:res_type] = ''
  end

  def view
    @columns = ['email', 'entity.tag', 'place.tag', 'role_ids']
    @users = User.all
    objects_order_by_from_params @users, params
    @users = @users.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@users, @columns, :id_column => 'id')
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
    @user.place_id = params[:user][:place_id]
    if !@user.save
      render :action => "new"
    end
  end

  def update
    @user = User.find(params[:id])
    @user.place_id = params[:user][:place_id]
    if !@user.save || !@user.update_attributes(params[:user])
      render :action => "edit"
    end
  end
end
