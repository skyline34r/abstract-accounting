require 'resource'

class DealsController < ApplicationController
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
    @columns = ['tag', 'entity.tag', 'rate', 'give.tag', 'take.tag', 'take.id',
                'take.class.name', 'isOffBalance']
    @deals = Deal.all
    if params[:_search]
      args = Hash.new
      if !params[:tag].nil?
        args['tag'] = {:like => params[:tag]}
      end
      if !params[:entity].nil?
        args['entity.tag'] = {:like => params[:entity]}
      end
      @deals = @deals.where args
    end
    case params[:sidx]
       when 'entity'
         params[:sidx] = 'entity.tag'
    end
    objects_order_by_from_params @deals, params
    @deals = @deals.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@deals, @columns, :id_column => 'id')
    end
  end

  def new
    @deal = Deal.new
  end

  def create
    @deal = Deal.new(params[:deal])
    if !@deal.save
      render :action => "new"
    else
      if params[:rules] != nil then
        idx = 0;
        while(params[:rules][idx] != nil) do
          @deal.rules.create :tag => params[:rules][idx]["tag"],
            :from_id => params[:rules][idx]["from_id"],
            :to_id => params[:rules][idx]["to_id"],
            :fact_side => params[:rules][idx]["fact_side"],
            :change_side => params[:rules][idx]["change_side"],
            :rate => params[:rules][idx]["rate"]
          idx += 1
        end
      end
    end
  end
  
end
