class QuotesController < ApplicationController

  def index
    session[:res_type] = 'money'
    @quotes = Quote.all
  end

  def new
    @quote = Quote.new
  end

  def create
    @quote = Quote.new(params[:quote])
    if !@quote.save
      render :action => "new"
    end
  end

end
