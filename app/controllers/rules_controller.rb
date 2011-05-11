class RulesController < ApplicationController
  def index
    session[:res_type] = ''
  end
end
