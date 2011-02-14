require 'resource'

class ResourcesController < ApplicationController

  def index
    @asset = Asset.select('id, tag, "asset" AS type')
    @money = Money.select('id, alpha_code AS tag, "money" AS type')
    @resources = @money + @asset
  end
  
end
