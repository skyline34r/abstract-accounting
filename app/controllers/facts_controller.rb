require 'float_accounting'

class FactsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    session[:res_type] = ''
    @fact = Fact.new
  end

  def create
    @fact = Fact.new(params[:fact])
    if @fact.save
      @txn = Txn.new(:fact => @fact)
      @txn.save
    end
  end

  def destroy
    @txn = Txn.find(params[:id])
    @txn.destroy
    @fact = Fact.find(params[:id])
    @fact.destroy
  end
end
