class HelpController < ApplicationController
  def index
    render "help/index", :layout => false
  end

  def show
    render "help/#{params[:id]}", :layout => false
  end

  def clear_notification
    Help.destroy_all
    render :json => { result: "clear" }
  end

  def notification
    ap Help.all
    if current_user.root?
      render :json => { result: "error" }
    elsif Help.find_by_user_id(current_user.id).nil?
      render :json => { result: "MESSAGE" }
    else
      render :json => { result: "error" }
    end
  end

  def help_notification_hide
    Help.create(user_id: current_user.id)
  end
end