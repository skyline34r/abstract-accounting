class UsersController < ApplicationController
  def index
    @users = User.all
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
