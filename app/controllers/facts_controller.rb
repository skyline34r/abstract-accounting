class FactsController < ApplicationController

  def index
    @fact = Fact.new
  end

  def create
    @fact = Fact.new(params[:fact])
    if !@fact.save
      render :action => "index"
    end
  end
  
end
