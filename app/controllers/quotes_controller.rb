class QuotesController < ApplicationController

  def index
    session[:res_type] = 'money'
    @quotes = Quote.all
  end

  def new
  end

  def create
  end
  
end
