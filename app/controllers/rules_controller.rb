class RulesController < ApplicationController
  before_filter :set_current_user

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

    @rules = Deal.find(params[:deal_id]).rules.to_a
    if params[:_search]
      args = Hash.new
      if !params[:tag].nil?
        args['tag'] = {:like => params[:tag]}
      end
      if !params[:to_tag].nil?
        args['to.tag'] = {:like => params[:to_tag]}
      end
      if !params[:from_tag].nil?
        args['from.tag'] = {:like => params[:from_tag]}
      end
      if !params[:rate].nil?
        args['rate'] = {:like => params[:rate]}
      end
      @rules = @rules.where args
    end
    case params[:sidx]
       when 'to_tag'
         params[:sidx] = 'to.tag'
      when 'from_tag'
        params[:sidx] = 'from.tag'
    end
    objects_order_by_from_params @rules, params
    @rules = @rules.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@rules, @columns, :id_column => 'id')
    end
  end
end
