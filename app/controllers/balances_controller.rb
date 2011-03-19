require 'resource.rb'

class BalancesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def index
    session[:res_type] = ''
    load_grid('')
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
    @balances = @balances.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@balances, @columns)
    end
  end

end
