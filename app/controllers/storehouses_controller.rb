require 'storehouse.rb'
require 'prawn'
require 'action_array'

class StorehousesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource
  before_filter :set_current_user

  def index
    session[:res_type] = ''
  end

  def view
    if params[:release].nil?
      real_amount = true
      @columns = ['place.tag', 'product.resource.tag', 'real_amount',
                  'amount', 'product.unit']
    else
      real_amount = false
      @columns = ['place.tag', 'product.resource.tag',
                  'amount', 'product.unit']
    end
    
    @storehouse = Storehouse.new(current_user.entity,
                                 current_user.place, real_amount)
    if params[:_search]
      args = Hash.new
      if !params[:place].nil?
        args['place.tag'] = {:like => params[:place]}
      end
      if !params[:resource].nil?
        args['product.resource.tag'] = {:like => params[:resource]}
      end
      if !params[:real_amount].nil?
        args['real_amount'] = {:like => params[:real_amount]}
      end
      if !params[:amount].nil?
        args['amount'] = {:like => params[:amount]}
      end
      if !params[:unit].nil?
        args['product.unit'] = {:like => params[:unit]}
      end
      @storehouse = @storehouse.where args
    end

    case params[:sidx]
      when 'place'
        params[:sidx] = 'place.tag'
      when 'resource'
        params[:sidx] = 'product.resource.tag'
      when 'unit'
        params[:sidx] = 'product.unit'
    end
    objects_order_by_from_params @storehouse, params

    @storehouse = @storehouse.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@storehouse, @columns,
                                               :id_column => 'product.resource.id')
    end
  end

  def new
    session[:res_type] = ''
  end

  def create
    @release = StorehouseRelease.new(:created => params[:date],
                                     :owner => current_user.entity,
                                     :place => current_user.place)
    if params[:to] != nil and params[:to].length > 0 then
      @release.to = params[:to]
    end
    if params[:resource_id] != nil then
      for i in 0..params[:resource_id].length-1
        @release.add_resource(Product.find_by_resource_id(params[:resource_id][i]),
                                                          params[:release_amount][i].to_f)
      end
    end
    if !@release.save then
      render :action => 'new'
    end
  end

  def releases
    session[:res_type] = ''
  end

  def list
    @columns = ['created', 'owner.tag', 'to.tag', 'place.tag', 'state']
    state = nil
    if params[:state] == "1"
      state = StorehouseRelease::INWORK
    elsif params[:state] == "2"
      state = StorehouseRelease::APPLIED
    elsif params[:state] == "3"
      state = StorehouseRelease::CANCELED
    end

    @releases = StorehouseRelease.find_all_by_owner_and_place_and_state(current_user.entity,
                                                                        current_user.place, state)

    if params[:_search]
      args = Hash.new
      if !params[:created].nil?
        args['created'] = {:like => params[:created]}
      end
      if !params[:owner].nil?
        args['owner.tag'] = {:like => params[:owner]}
      end
      if !params[:to].nil?
        args['to.tag'] = {:like => params[:to]}
      end
      if !params[:place].nil?
        args['place.tag'] = {:like => params[:place]}
      end
      @releases = @releases.where args
    end

    case params[:sidx]
      when 'owner'
        params[:sidx] = 'owner.tag'
      when 'to'
        params[:sidx] = 'to.tag'
      when 'place'
        params[:sidx] = 'place.tag'
    end

    objects_order_by_from_params @releases, params
    @releases = @releases.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@releases, @columns, :id_column => 'id')
    end
  end

  def show
    release = StorehouseRelease.find(params[:id])
    @place = release.place.tag
    @owner = release.owner.tag
    @date = release.created.strftime("%x")
    @to = release.to.tag
    @state = get_status(release.state)
    @disable_btns = (release.state != StorehouseRelease::INWORK)
  end

  def view_release
    @columns = ['product.resource.tag', 'amount', 'product.unit']
    release = StorehouseRelease.find(params[:id])
    @resources = release.resources
    objects_order_by_from_params @resources, params
    @resources = @resources.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@resources, @columns,
                                               :id_column => 'product.resource.id')
    end
  end

  def cancel
    StorehouseRelease.find(params[:id]).cancel
    render :action => 'releases'
  end

  def apply
    StorehouseRelease.find(params[:id]).apply
    render :action => 'releases'
  end

  def pdf
    sr = StorehouseRelease.find(params[:id])
    @tDate = t('storehouse.releaseList.date')
    @tPlace = t('storehouse.releaseList.place')
    @tOwner = t('storehouse.releaseList.owner')
    @tTo = t('storehouse.releaseList.to')
    @place = sr.place.tag
    @owner = sr.owner.tag
    @date = sr.created.to_date.to_s
    @to = sr.to.tag
    @header = [t('storehouse.entryList.resource'),
               t('storehouse.entryList.amount'),
               t('storehouse.entryList.unit')]
    @row = []
    sr.resources.each_with_index do |entry, idx|
      @row[idx] = [entry.product.resource.tag, entry.amount, entry.product.unit]
    end
   
    prawnto :prawn => {
      :page_size => 'A4',
      :left_margin => 50,
      :right_margin => 50,
      :top_margin => 24,
      :bottom_margin => 24},
      :filename=>"shipment_#{@date.gsub("/", "-")}.pdf"
    render :layout=>false
  end

  def get_status(id)
    case id
      when 1
        return t('storehouse.status.inwork')
      when 2
        return t('storehouse.status.canceled')
      when 3
        return t('storehouse.status.applied')
      else
        return t('storehouse.status.unknown')
    end
  end

  def waybill_list
    @columns = ['waybill.document_id', 'waybill.created', 'waybill.from.tag',
                'waybill.owner.tag', 'waybill.vatin', 'waybill.place.tag']
    @waybills = Storehouse.new(current_user.entity,
                               current_user.place).waybills

    if params[:_search]
      args = Hash.new
      if !params[:document_id].nil?
        args['waybill.document_id'] = {:like => params[:document_id]}
      end
      if !params[:created].nil?
        args['waybill.created'] = {:like => params[:created]}
      end
      if !params[:from].nil?
        args['waybill.from.tag'] = {:like => params[:from]}
      end
      if !params[:owner].nil?
        args['waybill.owner.tag'] = {:like => params[:owner]}
      end
      if !params[:vatin].nil?
        args['waybill.vatin'] = {:like => params[:vatin]}
      end
      if !params[:place].nil?
        args['waybill.place.tag'] = {:like => params[:place]}
      end
      @waybills = @waybills.where args
    end

    case params[:sidx]
      when 'document_id'
        params[:sidx] = 'waybill.document_id'
      when 'created'
        params[:sidx] = 'waybill.created'
      when 'from'
        params[:sidx] = 'waybill.from.tag'
      when 'owner'
        params[:sidx] = 'waybill.owner.tag'
      when 'vatin'
        params[:sidx] = 'waybill.vatin'
      when 'place'
        params[:sidx] = 'waybill.place.tag'
    end

    objects_order_by_from_params @waybills, params
    @waybills = @waybills.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@waybills, @columns,
                                               :id_column => 'waybill.id')
    end
  end

  def waybill_entries_list
    @columns = ['product.resource.tag', 'amount', 'product.unit']
    @entries = Storehouse.new(current_user.entity,
                               current_user.place).
                          waybill_by_id(params[:id].to_i).resources
    objects_order_by_from_params @entries, params
    @entries = @entries.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@entries, @columns,
                                               :id_column => 'product.resource.id')
    end
  end

  def return
    session[:res_type] = ''
  end

  def return_list
    @columns = ['place.tag', 'product.resource.tag',
                'amount', 'product.unit']
    @storehouse = Storehouse.taskmaster(current_user.entity,
                                        current_user.place)
    if params[:_search]
      args = Hash.new
      if !params[:resource].nil?
        args['product.resource.tag'] = {:like => params[:resource]}
      end
      if !params[:amount].nil?
        args['amount'] = {:like => params[:amount]}
      end
      if !params[:unit].nil?
        args['product.unit'] = {:like => params[:unit]}
      end
      @storehouse = @storehouse.where args
    end

    case params[:sidx]
      when 'resource'
        params[:sidx] = 'product.resource.tag'
      when 'unit'
        params[:sidx] = 'product.unit'
    end
    objects_order_by_from_params @storehouse, params

    @storehouse = @storehouse.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@storehouse, @columns,
                                               :id_column => 'product.resource.id')
    end
  end

  def return_resources
    role_ids = Array.new
    storehouse_roles = Role.where("roles.pages LIKE '%Storehouse%'")
    storehouse_roles.map do |r|
      role_ids << r.id
    end
    storehouse_worker = User.joins(:roles).
        where('place_id = ? and roles.id in (?)', current_user.place_id, role_ids).first

    @return = StorehouseReturn.new :created_at => params[:date],
                                   :from => Entity.where(:tag => params[:from]).first,
                                   :to => storehouse_worker.entity,
                                   :place => storehouse_worker.place

    if params[:resource_id] != nil then
      for i in 0..params[:resource_id].length-1
        @return.add_resource(Product.find_by_resource_id(params[:resource_id][i]),
                                                         params[:return_amount][i].to_f)
      end
    end

    if !@return.save then
      render :action => 'return'
    else
      render :action => 'resource_state'
    end
  end

  def resource_state
    session[:res_type] = ''
  end
end
