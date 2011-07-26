class AssetRealsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :set_current_user

  def index
  end

  def view
    @columns = ['tag', 'assets.empty?']
    base_reals = AssetReal.all
    if params[:_search]
      args = Hash.new
      if !params[:tag].nil?
        args['tag'] = {:like => params[:tag]}
      end
      base_reals = base_reals.where args
    end
    objects_order_by_from_params base_reals, params
    if session[:asset_real_id].nil?
      @asset_reals = base_reals.paginate(
        :page     => params[:page],
        :per_page => params[:rows])
    else
      page = 1
      begin
        @asset_reals = base_reals.paginate(
          :page     => page,
          :per_page => params[:rows])
        page += 1
      end while @asset_reals.where(:id => session[:asset_real_id]).empty?
      session[:asset_real_id] = nil
    end
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
    session[:asset_real_id] = @asset_real.id
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
    session[:asset_real_id] = @asset_real.id
  end

end
