class GeneralLedgersController < ApplicationController

  def index
    @general_ledgers = GeneralLedger.new
  end

end
