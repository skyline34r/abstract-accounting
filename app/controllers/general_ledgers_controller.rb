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
        alpha_code
      end
    }
    columns = ['fact.day', 'fact.resource.real_tag', 'fact.amount',
               'fact.from.tag', 'fact.to.tag', 'value', 'earnings']
    args = Hash.new
    case params[:sidx]
      when 'date'
        args[:order] = {'fact.day' => params[:sord]}
      when 'resource'
        args[:order] = {'resource.tag' => params[:sord]}
      when 'quantity'
        args[:order] = {'fact.amount' => params[:sord]}
      when 'debit'
        args[:order] = {'debit' => params[:sord]}
      when 'credit'
        args[:order] = {'credit' => params[:sord]}
    end
    if params[:_search]
      where = Hash.new
      if !params[:date].nil?
        where['fact.day'] = {:like => params[:date]}
      end
      if !params[:resource].nil?
        where['resource.tag'] = {:like => params[:resource]}
      end
      if !params[:quantity].nil?
        where['fact.amount'] = {:like => params[:quantity]}
      end
      if !params[:debit].nil?
        where['debit'] = {:like => params[:debit]}
      end
      if !params[:credit].nil?
        where['credit'] = {:like => params[:credit]}
      end
      args[:where] = where
    end
    general_ledgers = GeneralLedger.find(args)
    general_ledgers = general_ledgers.paginate(
     :page     => params[:page],
     :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(general_ledgers, columns,
                                               :id_column => 'fact.id')
    end
  end
end
