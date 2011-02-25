class FactsController < ApplicationController

  def index
    @fact = Fact.new
  end

  def create
  end
  
end
