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

    @quote = Quote.all
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
      @quote = @quote.where args
    end
    case params[:sidx]
       when 'resource'
         params[:sidx] = 'money.alpha_code'
    end
    objects_order_by_from_params @quote, params
    if session[:quote_id].nil?
      @quotes = @quote.paginate(
        :page     => params[:page],
        :per_page => params[:rows])
    else
      page = 1
      begin
        @quotes = @quote.paginate(
          :page     => page,
          :per_page => params[:rows])
        page += 1
      end while @quotes.where(:id => session[:quote_id]).first.nil?
      session[:quote_id] = nil
    end
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
    session[:quote_id] = @quote.id
  end

end
