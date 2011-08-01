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
    @columns = ['document_id', 'created', 'from.real_tag', 'owner.real_tag', 'vatin',
                'place.tag', 'has_in_the_storehouse?']

    base_waybills = Waybill
    unless params[:sidx].nil?
      if params[:sidx] == 'from'
        base_waybills = base_waybills
          .joins("INNER JOIN entities AS froms ON froms.id = waybills.from_id")
          .joins("LEFT OUTER JOIN entity_reals AS from_reals ON from_reals.id = froms.real_id")
          .order("CASE WHEN from_reals.id IS NULL THEN froms.tag ELSE from_reals.tag END " + params[:sord].upcase)
      elsif params[:sidx] == 'owner'
        base_waybills = base_waybills
          .joins("INNER JOIN entities AS owners ON owners.id = waybills.owner_id")
          .joins("LEFT OUTER JOIN entity_reals AS owner_reals ON owner_reals.id = owners.real_id")
          .order("CASE WHEN owner_reals.id IS NULL THEN owners.tag ELSE owner_reals.tag END " + params[:sord].upcase)
      elsif params[:sidx] == 'place'
        base_waybills = base_waybills
          .joins(:place)
          .order("places.tag " + params[:sord].upcase)
      else
        base_waybills = base_waybills
          .order("waybills." + params[:sidx] + " " + params[:sord].upcase)
      end
    end
    unless params[:_search].nil?
      unless params[:document_id].nil?
        base_waybills = base_waybills
          .where('lower(waybills.document_id) LIKE ?', "%#{params[:document_id].downcase}%")
      end
      unless params[:created].nil?
        base_waybills = base_waybills
          .where('lower(waybills.created) LIKE ?', "%#{params[:created].downcase}%")
      end
      unless params[:vatin].nil?
        base_waybills = base_waybills
          .where('lower(waybills.vatin) LIKE ?', "%#{params[:vatin].downcase}%")
      end
      unless params[:place].nil?
        base_waybills = base_waybills
          .joins(:place)
          .where('lower(places.tag) LIKE ?', "%#{params[:place].downcase}%")
      end
      unless params[:from].nil?
        base_waybills = base_waybills
          .joins("INNER JOIN entities AS froms ON froms.id = waybills.from_id")
          .joins("LEFT OUTER JOIN entity_reals AS from_reals ON from_reals.id = froms.real_id")
          .where('lower(CASE WHEN from_reals.id IS NULL THEN froms.tag ELSE from_reals.tag END) LIKE ?', "%#{params[:from].downcase}%")
      end
      unless params[:owner].nil?
        base_waybills = base_waybills
          .joins("INNER JOIN entities AS owners ON owners.id = waybills.owner_id")
          .joins("LEFT OUTER JOIN entity_reals AS owner_reals ON owner_reals.id = owners.real_id")
          .where('lower(CASE WHEN owner_reals.id IS NULL THEN owners.tag ELSE owner_reals.tag END) LIKE ?', "%#{params[:owner].downcase}%")
      end
    end
    base_waybills = base_waybills.not_disabled
    base_waybills = base_waybills.find_by_owner_and_place(current_user.entity, current_user.place)
    @waybills = base_waybills.paginate(
      :page     => params[:page],
      :per_page => params[:rows])

    if request.xhr?
      render :json => abstract_json_for_jqgrid(@waybills, @columns, :id_column => 'id')#,
        #:params => {'has_in_the_storehouse?' => nil})#Storehouse.new(current_user.entity, current_user.place)})
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
