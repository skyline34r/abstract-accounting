require 'resource.rb'

class BalancesController < ApplicationController
  
  def index
    session[:res_type] = ''
  end

  def load
    Money.class_exec {
      def tag
        return alpha_code
      end
    }
    @columns = ['deal.tag', 'deal.entity.tag', 'deal.give.tag', 'amount',
                'value', 'side']
    if params[:date] == ''
      @balances = BalanceSheet.new DateTime.now
    else
      @balances = BalanceSheet.new DateTime.strptime(params[:date], '%m/%d/%Y')
    end
    @balances = @balances.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@balances, @columns)
    end
  end

end
