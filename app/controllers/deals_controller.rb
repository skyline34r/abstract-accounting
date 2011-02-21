class DealsController < ApplicationController

  def index
    @columns = ['tag', 'entity_tag', 'id', 'rate', 'entity_id', 'give_id',
                'give_type', 'take_id', 'take_type']
    @deals = Deal.joins('INNER JOIN entities ON entities.id = deals.entity_id')
                 .select('"deals".*, "entities".tag AS entity_tag');
    @deals = @deals.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => json_for_jqgrid(@deals, @columns)
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
