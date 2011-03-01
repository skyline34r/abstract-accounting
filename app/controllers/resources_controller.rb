require 'resource'

class ResourcesController < ApplicationController

  def index
    @columns = ['tag', 'type', 'id', 'code']
    @asset = Asset.select('id, tag, "Asset" AS type, 0 AS code')
    @money = Money.select('id, alpha_code AS tag,
                           num_code AS code, "Money" AS type')
    @resources = @money + @asset
    @resources = @resources.sort do |x,y|
      if params[:sidx] == 'tag'
        if params[:sord] == 'asc'
          x.tag <=> y.tag
        else
          y.tag <=> x.tag
        end
      else
        if params[:sord] == 'asc'
          x.type <=> y.type
        else
          y.type <=> x.type
        end
      end
    end
    @resources = @resources.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => json_for_jqgrid(@resources, @columns)
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

  def get_asset_tag
    @resource = Asset.find(params[:id]).tag
  end

  def get_money_tag
    @resource = Money.find(params[:id]).alpha_code
  end
end
