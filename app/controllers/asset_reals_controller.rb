class AssetRealsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
  end

  def view
    @columns = ['tag', 'assets.empty?']
    @asset_reals = AssetReal.all
    if params[:_search]
      args = Hash.new
      if !params[:tag].nil?
        args['tag'] = {:like => params[:tag]}
      end
      @asset_reals = @asset_reals.where args
    end
    objects_order_by_from_params @asset_reals, params
    @asset_reals = @asset_reals.paginate(
      :page     => params[:page],
      :per_page => params[:rows])
    if request.xhr?
      render :json => abstract_json_for_jqgrid(@asset_reals, @columns, :id_column => 'id')
    end
  end

  def new
    @asset_real = AssetReal.new
  end

  def edit
    @asset_real = AssetReal.find(params[:id])
  end

  def create
    @asset_real = AssetReal.new(params[:asset_real])
    @asset_real.asset_ids = params[:assets].collect { |id| id.to_i } if
        !params[:assets].nil? and !params[:assets].empty? and
            params[:assets][0] != "empty"
    unless @asset_real.save
      render :action => "new"
    end
  end

  def update
    @asset_real = AssetReal.find(params[:id])
    unless params[:assets].nil?
      if !params[:assets].empty? and params[:assets][0] != "empty"
        @asset_real.asset_ids = params[:assets].collect { |id| id.to_i }
      elsif params[:assets][0] == "empty"
        @asset_real.assets.clear
      end
    end
    unless @asset_real.save and @asset_real.update_attributes(params[:asset_real])
      render :action => "edit"
    end
  end

end
