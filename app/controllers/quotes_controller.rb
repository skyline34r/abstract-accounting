class QuotesController < ApplicationController

  def index
    session[:res_type] = 'money'
    @quotes = Quote.all
  end

  def new
    @quote = Quote.new
  end

  def create
  end
  
end
