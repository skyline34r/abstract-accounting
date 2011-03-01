require 'float_accounting'

class FactsController < ApplicationController

  def index
    @fact = Fact.new
  end

  def create
    @fact = Fact.new(params[:fact])
    if @fact.save
      @txn = Txn.new(:fact => @fact)
      @txn.save
    end
  end

end
