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

end
