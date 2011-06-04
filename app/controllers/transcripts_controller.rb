require 'float_accounting'

class TranscriptsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
    session[:res_type] = ''
  end

  def load
    if params[:empty]
      if request.xhr?
        render :json => abstract_json_for_jqgrid('')
      end
    else
      @columns = ['id', 'fact.day', 'fact.from.tag', 'fact.to.tag', 'fact.amount',
                  'value', 'earnings']
      deal = Deal.find(params[:deal_id])
      @transcript = Transcript.new(deal,
                                   DateTime.strptime(params[:start], '%m/%d/%Y'),
                                   DateTime.strptime(params[:stop], '%m/%d/%Y'))
      if params[:source] == 'grid'
        if params[:_search]
          args = Hash.new
          if !params[:date].nil?
            args['fact.day'] = {:like => params[:date]}
          end
          @transcript = @transcript.where args
        end
        case params[:sidx]
          when 'fact.day'
            params[:sidx] = 'place.tag'
        end
        objects_order_by_from_params @transcript, params
        @transcript = @transcript.paginate(
          :page     => params[:page],
          :per_page => params[:rows])
        if request.xhr?
          render :json => abstract_json_for_jqgrid(@transcript, @columns, :id_column => 'id')
        end
      end
    end
  end

end
