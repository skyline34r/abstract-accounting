require 'float_accounting'

class TranscriptsController < ApplicationController
  
  def index
    session[:res_type] = ''
    if request.xhr?
      render :json => abstract_json_for_jqgrid('')
    end
  end

  def load
    deal = Deal.find(params[:deal_id])
    @transcript = Transcript.new(deal,
                                 DateTime.strptime(params[:start], '%m/%d/%Y'),
                                 DateTime.strptime(params[:stop], '%m/%d/%Y'))
  end

end
