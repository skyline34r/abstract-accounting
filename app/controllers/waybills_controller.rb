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
    @columns = ['waybill.document_id', 'waybill.created', 'waybill.from.real_tag', 'waybill.owner.real_tag',
                'waybill.vatin', 'waybill.place.tag', 'has_in_the_warehouse']
    search = Hash.new
    if params[:_search]
      search[:document_id] = {:like => params[:document_id]} unless params[:document_id].nil?
      search[:created] = {:like => params[:created]} unless params[:created].nil?
      search[:vatin] = {:like => params[:vatin]} unless params[:vatin].nil?
      search[:place] = {:like => params[:place]} unless params[:place].nil?
      search[:from] = {:like => params[:from]} unless params[:from].nil?
      search[:owner] = {:like => params[:owner]} unless params[:owner].nil?
    end
    #base_waybills = base_waybills.not_disabled.by_storekeeper(current_user.entity, current_user.place)
    base_waybills = Waybill.with_warehouse_state :entity => current_user.entity,
                                                 :place => current_user.place,
                                                 :sidx => params[:sidx],
                                                 :sord => params[:sord],
                                                 :search => search
    @waybills = base_waybills.paginate(
      :page     => params[:page],
      :per_page => params[:rows])

    if request.xhr?
      render :json => abstract_json_for_jqgrid(@waybills, @columns, :id_column => 'waybill.id')
    end
  end

  def show
    @columns = ['product.resource.real_tag', 'amount', 'product.unit']
    @entries = Waybill.find(params[:id]).resources
    @entries = @entries.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@entries, @columns)
    end
  end

  def edit
    authorize! :destroy, Waybill
    @waybill = Waybill.not_disabled.find(params[:id])
  end

  def disable
    authorize! :destroy, Waybill
    @waybill = Waybill.not_disabled.find(params[:id])
    if @waybill.disable(params[:waybill][:comment])
      render :action => :index
    else
      render :action => :edit
    end
  end
end
