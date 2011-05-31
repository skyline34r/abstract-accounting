class WaybillsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
    session[:res_type] = ''
  end

  def new
    @waybill = Waybill.new
  end

  def create
    @waybill = Waybill.new(params[:waybill])
    if current_user != nil && current_user.entity != nil &&
       current_user.place != nil then
      @waybill.owner = current_user.entity
      @waybill.place = current_user.place
    end
    if params[:entry_resource] != nil then
      for i in 0..params[:entry_resource].length-1
        if params[:entry_resource][i].length != 0 or
           params[:entry_unit][i].length != 0 or
           params[:entry_amount][i].length != 0
          @waybill.add_resource params[:entry_resource][i],
                                params[:entry_unit][i],
                                params[:entry_amount][i].to_f
        end
      end
    end
    if @waybill.save then
      render :action => 'index'
    else
      render :action => 'new'
    end
  end

  def view
    @columns = ['document_id', 'created', 'from.tag', 'owner.tag', 'vatin',
                'place.tag', 'has_in_the_storehouse?']
    @waybills = Waybill.find_by_owner_and_place(current_user.entity,
                                                current_user.place).paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@waybills, @columns, :id_column => 'id',
        :params => {'has_in_the_storehouse?' => Storehouse.new(current_user.entity, current_user.place)})
    end
  end

  def show
    @columns = ['product.resource.tag', 'amount', 'product.unit']
    @entries = Waybill.find(params[:id]).resources
    @entries = @entries.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@entries, @columns)
    end
  end
end
