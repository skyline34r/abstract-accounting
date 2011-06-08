require 'resource'

class HomeController < ApplicationController

  def index
    session[:res_type] = ''
  end

  def main
    session[:res_type] = ''
  end
end
