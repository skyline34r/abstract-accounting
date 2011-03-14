class GeneralLedgerController < ApplicationController

  def index
    @general_ledger = GeneralLedger.new
  end

end
