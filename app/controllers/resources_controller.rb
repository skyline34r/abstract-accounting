require 'resource'

class ResourcesController < ApplicationController
  before_filter :authenticate_user!

  def index
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
      @resources = @money
    else
      @asset = Asset.all
      @resources = @money + @asset
    end
    @resources = @resources.sort do |x,y|
      if params[:sidx] == 'tag'
        if params[:sord] == 'asc'
          x.tag <=> y.tag
        else
          y.tag <=> x.tag
        end
      else
        if params[:sord] == 'asc'
          x.class.name <=> y.class.name
        else
          y.class.name <=> x.class.name
        end
      end
    end
    @resources = @resources.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
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
  end

  def create_money
    @resource = Money.new(params[:money])
    if !@resource.save
      render :action => "new_money"
    end
  end

  def update_asset
    @resource = Asset.find(params[:id])
    if !@resource.update_attributes(params[:asset])
      render :action => "edit_asset"
    end
  end

  def update_money
    @resource = Money.find(params[:id])
    if !@resource.update_attributes(params[:money])
      render :action => "edit_money"
    end
  end

end
