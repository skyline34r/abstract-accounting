class DealsController < ApplicationController

  def index
    session[:res_type] = ''
    @columns = ['tag', 'entity.tag', 'rate', 'give.tag', 'take.tag']
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
