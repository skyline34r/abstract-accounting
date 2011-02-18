class DealsController < ApplicationController

  def index
    @deals = Deal.all
  end

  def new
  end

  def create
  end
  
end
