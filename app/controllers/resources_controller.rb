require 'resource'

class ResourcesController < ApplicationController

  def index
    @asset = Asset.select('id, tag, "asset" AS type')
    @money = Money.select('id, alpha_code AS tag, "money" AS type')
    @resources = @money + @asset
  end

  def new_asset
    @asset = Asset.new
  end

  def new_money
    @money = Money.new
  end

  def edit_asset
    @asset = Asset.find(params[:id])
  end

  def edit_money
    @money = Money.find(params[:id])
  end

  def create_asset
    @asset = Asset.new(params[:asset])
    if !@asset.save
      render :action => "new_asset"
    end
  end

  def create_money
    @money = Money.new(params[:money])
    if !@money.save
      render :action => "new_money"
    end
  end

  def update_asset
    @asset = Asset.find(params[:id])
    if !@asset.update_attributes(params[:asset])
      render :action => "edit_asset"
    end
  end

  def update_money
    @money = Money.find(params[:id])
    if !@money.update_attributes(params[:money])
      render :action => "edit_money"
    end
  end
end
