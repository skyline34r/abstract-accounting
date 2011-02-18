class DealsController < ApplicationController

  def index
    @deals = Deal.all
  end

  def new
    @deal = Deal.new
  end

  def create
  end
  
end
