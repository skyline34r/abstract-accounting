require 'resource'

class DealsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

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
    @deals = Deal.all;
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
    end
  end
  
end
