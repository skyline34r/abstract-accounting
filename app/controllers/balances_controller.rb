require 'resource.rb'

class BalancesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user
  
  def index
    session[:res_type] = ''
  end

  def load
    columns = ['deal.tag', 'deal.entity.real_tag', 'deal.give.real_tag', 'amount',
               'value', 'side']
    args = Hash.new
    if !params.nil? && !params[:date].nil? && !params[:date].empty?
      args[:day] = DateTime.strptime(params[:date], '%m/%d/%Y')
    end
    case params[:sidx]
      when 'deal'
        args[:order] = {'deal.tag' => params[:sord]}
      when 'entity'
        args[:order] = {'entity.tag' => params[:sord]}
      when 'resource'
        args[:order] = {'resource.tag' => params[:sord]}
      when 'amount'
        if params[:accounting]
          args[:order] = {'accounting.debit' => params[:sord]}
        else
          args[:order] = {'physical.debit' => params[:sord]}
        end
      when 'value'
        if params[:accounting]
          args[:order] = {'accounting.credit' => params[:sord]}
        else
          args[:order] = {'physical.credit' => params[:sord]}
        end
    end
    if params[:_search]
      where = Hash.new
      unless params[:deal].nil?
        where['deal.tag'] = {:like => params[:deal]}
      end
      unless params[:entity].nil?
        where['entity.tag'] = {:like => params[:entity]}
      end
      unless params[:resource].nil?
        where['resource.tag'] = {:like => params[:resource]}
      end
      unless params[:amount].nil?
        if params[:accounting]
          where['accounting.debit'] = {:like => params[:amount]}
        else
          where['physical.debit'] = {:like => params[:amount]}
        end
      end
      unless params[:value].nil?
        if params[:accounting]
          where['accounting.credit'] = {:like => params[:value]}
        else
          where['physical.credit'] = {:like => params[:value]}
        end
      end
      args[:where] = where
    end

    sheet_balances = BalanceSheet.find(args)
    balances = sheet_balances.balances.paginate(
     :page     => params[:page],
     :per_page => params[:rows])

    if request.xhr?
      render :json => abstract_json_for_jqgrid(balances, columns)
    end
  end

  def total
    args = Hash.new
    if !params.empty? && !params[:date].nil? && !params[:date].empty?
      args[:day] = DateTime.strptime(params[:date], '%m/%d/%Y')
    end
    args[:totals] = true
    bs_totals = BalanceSheet.new(args)
    @assets = bs_totals.assets
    @liabilities = bs_totals.liabilities
  end
end
