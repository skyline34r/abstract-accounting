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
    @columns = ['tag', 'entity.real_tag', 'rate', 'give.tag', 'take.tag', 'take.id',
                'take.class.name', 'isOffBalance']
    base_deals = Deal
    unless params[:_search].nil?
      unless params[:tag].nil?
        base_deals = base_deals
          .where('lower(deals.tag) LIKE ?', "%#{params[:tag].downcase}%")
      end
      unless params[:entity].nil?
        base_deals = base_deals.joins(:entity)
          .joins("LEFT OUTER JOIN entity_reals ON entity_reals.id = entities.real_id")
          .where('lower(CASE WHEN entity_reals.id IS NULL THEN entities.tag ELSE entity_reals.tag END) LIKE ?', "%#{params[:entity].downcase}%")
      end
    end
    unless params[:sidx].nil?
      if params[:sidx] == "entity"
        base_deals = base_deals.joins(:entity)
          .joins("LEFT OUTER JOIN entity_reals ON entity_reals.id = entities.real_id")
          .order("CASE WHEN entity_reals.id IS NULL THEN entities.tag ELSE entity_reals.tag END " + params[:sord].upcase)
      else
        base_deals = base_deals.order('deals.' + params[:sidx] + " " + params[:sord].upcase)
      end
    end
    @deal = base_deals
    if session[:deal_id].nil?
      @deals = @deal.paginate(
        :page     => params[:page],
        :per_page => params[:rows])
    else
      page = 1
      begin
        @deals = @deal.paginate(
          :page     => page,
          :per_page => params[:rows])
        page += 1
      end while @deals.where(:id => session[:deal_id]).first.nil?
      session[:deal_id] = nil
    end
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
    session[:deal_id] = @deal.id
  end
  
end
