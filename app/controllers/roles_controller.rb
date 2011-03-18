class RolesController < ApplicationController

  def index
    @roles = Role.all
  end

  def new
  end

  def create
  end

end
