require 'float_accounting'

class TranscriptsController < ApplicationController
  
  def index
    session[:res_type] = ''
    if request.xhr?
      render :json => abstract_json_for_jqgrid('')
    end
  end

  def load
    @columns = ['id', 'fact.day', 'fact.from.tag', 'fact.to.tag', 'fact.amount',
                'value', 'earnings']
    deal = Deal.find(params[:deal_id])
    @transcript = Transcript.new(deal,
                                 DateTime.strptime(params[:start], '%m/%d/%Y'),
                                 DateTime.strptime(params[:stop], '%m/%d/%Y'))
    if params[:source] == 'grid'
      @transcript = @transcript.paginate(
        :page     => params[:page],
        :per_page => params[:rows],
        :order    => order_by_from_params(params))
      if request.xhr?
        render :json => abstract_json_for_jqgrid(@transcript, @columns, :id_column => 'id')
      end
    else
      @total_credits = @transcript.total_credits
      @total_credits_diff = @transcript.total_credits_diff
      @total_credits_value = @transcript.total_credits_value
      @total_debits = @transcript.total_debits
      @total_debits_diff = @transcript.total_debits_diff
      @total_debits_value = @transcript.total_debits_value
    end
  end

end
