class BalancesController < ApplicationController

  def index
    Money.class_exec {
      def tag
        return alpha_code
      end
    }

    session[:res_type] = ''
    @columns = ['deal.tag', 'deal.entity.tag', 'deal.give.tag', 'amount',
                'value', 'side']
    @balances = BalanceSheet.new DateTime.now
    @balances = @balances.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@balances, @columns)
    end
  end

end
