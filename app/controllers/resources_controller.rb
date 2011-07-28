require 'resource'

class ResourcesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :asset
  load_and_authorize_resource :money
  before_filter :set_current_user

  def index
  end

  def view
    @columns = ['tag', 'class.name', 'id', 'num_code']

    Money.class_exec {
      def uid
        return self.class.name + self.id.to_s
      end
      def tag
        return alpha_code
      end
    }

    Asset.class_exec {
      def uid
        return self.class.name + self.id.to_s
      end
      def num_code
        return 0
      end
    }

    @resources = nil
    if session[:res_type] == 'asset'
      base_assets = nil
      unless params[:sidx].nil?
        base_assets = Asset.order('assets.' + params[:sidx] + " " + params[:sord].upcase)
      end
      unless params[:_search].nil?
        base_assets = (base_assets.nil? ? Asset.where('lower(assets.tag) LIKE ?', "%#{params[:tag].downcase}%") :
            base_assets.where('lower(assets.tag) LIKE ?', "%#{params[:tag].downcase}%")) unless params[:tag].nil?
      end
      base_assets = (base_assets.nil? ? Asset.where('real_id is NULL') :
          base_assets.where('real_id is NULL')) if params[:filter] == "unassigned"
      base_assets = (base_assets.nil? ? Asset.all : base_assets) if @resources.nil?

      if session[:resource_id].nil?
        @resources = base_assets.paginate(
          :page     => params[:page],
          :per_page => params[:rows])
      else
        page = 1
        begin
          @resources = base_assets.paginate(
            :page     => page,
            :per_page => params[:rows])
          page += 1
        end while @resources.where(:uid => session[:resource_id]).first.nil?
        session[:resource_id] = nil
      end
      if request.xhr?
        render :json => abstract_json_for_jqgrid(@resources, @columns, :id_column => 'id')
      end
    else
      resource = Money.all
      if session[:res_type] != 'money'
        resource = resource + Asset.all
      end
      if params[:_search]
        args = Hash.new
        if !params[:tag].nil?
          args['tag'] = {:like => params[:tag]}
        end
        if !params[:type].nil?
          args['class.name'] = {:like => params[:type]}
        end
        resource = resource.where args
      end
      case params[:sidx]
         when 'type'
           params[:sidx] = 'class.name'
      end
      objects_order_by_from_params resource, params
      if session[:resource_id].nil?
        @resources = resource.paginate(
          :page     => params[:page],
          :per_page => params[:rows])
      else
        page = 1
        begin
          @resources = resource.paginate(
            :page     => page,
            :per_page => params[:rows])
          page += 1
        end while @resources.where(:uid => session[:resource_id]).first.nil?
        session[:resource_id] = nil
      end
      if request.xhr?
        render :json => abstract_json_for_jqgrid(@resources, @columns, :id_column => 'uid')
      end
    end
  end

  def asset_select
    @with_check = false
    @assets = nil
    unless params[:real_id].nil?
      @list_url = asset_surrogates_url :real_id => params[:real_id]
      if params[:type] == "edit"
        @with_check = true
        @list_url += "?filter=unassigned"
        @assets = Asset.where('real_id = ?', params[:real_id])
      end
    else
      session[:res_type] = 'asset'
      @list_url = view_resources_url + "?filter=unassigned"
      @with_check = true
    end
  end

  def asset_surrogates
    @columns = ['tag', 'real.nil?']
    base_assets = nil
    unless params[:sidx].nil?
      base_assets = Asset.order(params[:sidx] + " " + params[:sord].upcase)
    end
    unless params[:_search].nil? or params[:tag].nil?
      base_assets = (base_assets.nil? ? Asset.where('lower(tag) LIKE ?', "%#{params[:tag].downcase}%") :
          base_assets.where('lower(tag) LIKE ?', "%#{params[:tag].downcase}%"))
    end
    @assets = (base_assets.nil? ?
        Asset.find_all_by_real_id(params[:real_id]) :
        base_assets.find_all_by_real_id(params[:real_id])) if params[:filter].nil?
    @assets = (base_assets.nil? ?
        Asset.where('real_id is NULL') :
        base_assets.where('real_id is NULL')) if params[:filter] == "unassigned"
    @assets = @assets.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@assets, @columns, :id_column => 'id')
    end
  end

  def new_asset
    @resource = Asset.new
  end

  def new_money
    @resource = Money.new
  end

  def edit_asset
    @resource = Asset.find(params[:id])
  end

  def edit_money
    @resource = Money.find(params[:id])
  end

  def create_asset
    @resource = Asset.new(params[:asset])
    if !@resource.save
      render :action => "new_asset"
    end
    session[:resource_id] = @resource.class.name + @resource.id.to_s
  end

  def create_money
    @resource = Money.new(params[:money])
    if !@resource.save
      render :action => "new_money"
    end
    session[:resource_id] = @resource.class.name + @resource.id.to_s
  end

  def update_asset
    @resource = Asset.find(params[:id])
    if !@resource.update_attributes(params[:asset])
      render :action => "edit_asset"
    end
    session[:resource_id] = @resource.class.name + @resource.id.to_s
  end

  def update_money
    @resource = Money.find(params[:id])
    if !@resource.update_attributes(params[:money])
      render :action => "edit_money"
    end
    session[:resource_id] = @resource.class.name + @resource.id.to_s
  end

end
