require 'resource.rb'

class GeneralLedgersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
    session[:res_type] = ''
  end

  def view
    Money.class_exec {
      def tag
        return alpha_code
      end
    }
    @columns = ['fact.day', 'fact.resource.real_tag', 'fact.amount', 'fact.from.tag',
                'fact.to.tag', 'value', 'earnings']
    @general_ledgers = GeneralLedger.new
    if params[:_search]
      args = Hash.new
      if !params[:date].nil?
        args['fact.day'] = {:like => params[:date]}
      end
      if !params[:resource].nil?
        args['fact.resource.real_tag'] = {:like => params[:resource]}
      end
      if !params[:quantity].nil?
        args['fact.amount'] = {:like => params[:quantity]}
      end
      @general_ledgers = @general_ledgers.where args
    end
    case params[:sidx]
      when 'date'
         params[:sidx] = 'fact.day'
      when 'resource'
         params[:sidx] = 'fact.resource.real_tag'
      when 'quantity'
        params[:sidx] = 'fact.amount'
    end
    objects_order_by_from_params @general_ledgers, params
    @general_ledgers = @general_ledgers.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@general_ledgers, @columns, :id_column => 'fact.id')
    end
  end
end
