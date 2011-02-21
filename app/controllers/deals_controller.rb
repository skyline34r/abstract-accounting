class DealsController < ApplicationController

  def index
    @deals = Deal.all
  end

  def new
    @deal = Deal.new
  end

  def create
    @deal = Deal.new(params[:deal])
    if !@deal.save
      render :action => "new"
    end
  end
  
end
