require 'resource.rb'

class GeneralLedgersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    Money.class_exec {
      def tag
        return alpha_code
      end
    }
    session[:res_type] = ''
    @columns = ['fact.day', 'fact.resource.tag', 'fact.amount', 'fact.from.tag',
                'fact.to.tag', 'value', 'earnings']
    @general_ledgers = GeneralLedger.new
    @general_ledgers = @general_ledgers.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@general_ledgers, @columns)
    end
  end

end
