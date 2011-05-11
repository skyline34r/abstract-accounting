class RulesController < ApplicationController
  def index
    session[:res_type] = ''
  end

  def view
    session[:res_type] = ''
    @deal_id = params[:deal_id]
  end

  def data
    @columns = ['tag', 'to.id', 'to.tag', 'from.id', 'from.tag', 'rate',
                'change_side', 'fact_side']
    @rules = Deal.find(params[:deal_id]).rules.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@rules, @columns, :id_column => 'id')
    end
  end
end
