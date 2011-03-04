require 'float_accounting'

class QuotesController < ApplicationController

  def index
    session[:res_type] = 'money'
    @columns = ['money_tag', 'day', 'rate', 'id', 'money_id']
    @quotes = Quote.joins('INNER JOIN money ON money.id = quotes.money_id')
                   .select('"quotes".*, "money".alpha_code AS money_tag');
    @quotes = @quotes.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => json_for_jqgrid(@quotes, @columns)
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
