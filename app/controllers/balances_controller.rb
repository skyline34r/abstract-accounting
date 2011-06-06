require 'resource.rb'

class BalancesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user
  
  def index
    session[:res_type] = ''
  end

  def load
    load_grid(params[:date])
  end

  def load_grid(date)
    Money.class_exec {
      def tag
        return alpha_code
      end
    }
    @columns = ['deal.tag', 'deal.entity.tag', 'deal.give.tag', 'amount',
                'value', 'side']
    if date == ''
      @balances = BalanceSheet.new DateTime.now
    else
      @balances = BalanceSheet.new DateTime.strptime(date, '%m/%d/%Y')
    end
    @assets = @balances.assets
    @liabilities = @balances.liabilities

    if params[:_search]
      args = Hash.new
      if !params[:deal].nil?
        args['deal.tag'] = {:like => params[:deal]}
      end
      if !params[:entity].nil?
        args['deal.entity.tag'] = {:like => params[:entity]}
      end
      if !params[:resource].nil?
        args['deal.give.tag'] = {:like => params[:resource]}
      end
      @balances = @balances.where args
    end
    case params[:sidx]
      when 'deal'
        params[:sidx] = 'deal.tag'
      when 'entity'
        params[:sidx] = 'deal.entity.tag'
      when 'resource'
        params[:sidx] = 'deal.give.tag'
    end
    objects_order_by_from_params @balances, params
    @balances = @balances.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@balances, @columns)
    end
  end

end
