require 'float_accounting'
require 'resource'

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
    if params[:_search]
      args = Hash.new
      if !params[:resource].nil?
        args['money.alpha_code'] = {:like => params[:resource]}
      end
      if !params[:day].nil?
        args['day'] = {:like => params[:day]}
      end
      if !params[:rate].nil?
        args['rate'] = {:like => params[:rate]}
      end
      @quotes = @quotes.where args
    end
    case params[:sidx]
       when 'resource'
         params[:sidx] = 'money.alpha_code'
    end
    objects_order_by_from_params @quotes, params
    @quotes = @quotes.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@quotes, @columns, :id_column => 'id')
    end
  end

  def new
    session[:res_type] = 'money'
    @quote = Quote.new
  end

  def create
    @quote = Quote.new(params[:quote])
    if !@quote.save
      render :action => "new"
    end
  end

end
