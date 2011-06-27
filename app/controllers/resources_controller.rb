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

    @money = Money.all
    if (session[:res_type] == 'money')
      @resource = @money
    else
      @asset = Asset.all
      @resource = @money + @asset
    end

    if params[:_search]
      args = Hash.new
      if !params[:tag].nil?
        args['tag'] = {:like => params[:tag]}
      end
      if !params[:type].nil?
        args['class.name'] = {:like => params[:type]}
      end
      @resource = @resource.where args
    end
    case params[:sidx]
       when 'type'
         params[:sidx] = 'class.name'
    end
    objects_order_by_from_params @resource, params
    if session[:resource_id].nil?
      @resources = @resource.paginate(
        :page     => params[:page],
        :per_page => params[:rows])
    else
      page = 1
      begin
        @resources = @resource.paginate(
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
