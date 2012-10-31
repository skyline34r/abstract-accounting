class HelpController < ApplicationController
  def index
    render "help/index", :layout => false
  end

  def show
    render "help/#{params[:id]}", :layout => false
  end
end