require 'float_accounting'

class FactsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
    session[:res_type] = ''
    @fact = Fact.new
  end

  def create
    @fact = Fact.new(params[:fact])
    begin
      Fact.transaction do
        @fact.save!
        @txn = Txn.new(:fact => @fact)
        @txn.save!
      end
    rescue
      render :action => "index"
    end
  end

  def destroy
    @txn = Txn.find(params[:id])
    @txn.destroy
    @fact = Fact.find(params[:id])
    @fact.destroy
  end
end
