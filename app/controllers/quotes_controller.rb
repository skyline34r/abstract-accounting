require 'float_accounting'

class QuotesController < ApplicationController

  def index
    session[:res_type] = 'money'
    @columns = ['money.alpha_code', 'day', 'rate']
    @quotes = Quote.all.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@quotes, @columns, :id_column => 'id')
    end
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
