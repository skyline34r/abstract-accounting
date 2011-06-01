require 'float_accounting'

class QuotesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
    session[:res_type] = 'money'
  end

  def view
    @columns = ['money.alpha_code', 'day', 'rate']
    @quotes = Quote.all
    objects_order_by_from_params @quotes, params
    @quotes = @quotes.paginate(
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
