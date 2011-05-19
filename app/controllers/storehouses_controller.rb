require 'storehouse.rb'
require 'prawn'

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
                                 current_user.place, real_amount).paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
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
    @releases = StorehouseRelease.find_all_by_owner_and_place_and_state(current_user.entity,
                                         current_user.place).paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
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
  end

  def view_release
    @columns = ['product.resource.tag', 'amount', 'product.unit']
    release = StorehouseRelease.find(params[:id])
    @resources = release.resources.paginate(
      :page     => params[:page],
      :per_page => params[:rows],
      :order    => order_by_from_params(params))
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

end
