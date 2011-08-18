class UsersController < ApplicationController
  before_filter :set_current_user

  def index
    session[:res_type] = ''
  end

  def view
    @columns = ['email', 'entity.real_tag', 'place.tag', 'role_ids']
    @user = User.all
    if params[:_search]
      args = Hash.new
      if !params[:email].nil?
        args['email'] = {:like => params[:email]}
      end
      if !params[:entity].nil?
        args['entity.real_tag'] = {:like => params[:entity]}
      end
      if !params[:place].nil?
        args['place.tag'] = {:like => params[:place]}
      end
      @user = @user.where args
    end
    case params[:sidx]
      when 'entity'
        params[:sidx] = 'entity.real_tag'
      when 'place'
        params[:sidx] = 'place.tag'
    end
    objects_order_by_from_params @user, params
    if session[:user_id].nil?
      @users = @user.paginate(
        :page     => params[:page],
        :per_page => params[:rows])
    else
      page = 1
      begin
        @users = @user.paginate(
          :page     => page,
          :per_page => params[:rows])
        page += 1
      end while @users.where(:id => session[:user_id]).first.nil?
      session[:user_id] = nil
    end
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
    session[:user_id] = @user.id
  end

  def update
    @user = User.find(params[:id])
    if !params[:user][:password].nil? && params[:user][:password].length != 0
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if !@user.save
        render :action => "edit"
      end
    else
      @user.place_id = params[:user][:place_id]
      if !@user.save || !@user.update_attributes(params[:user])
        render :action => "edit"
      end
    end
    session[:user_id] = @user.id
  end
end
