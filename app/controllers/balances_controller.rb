class BalancesController < ApplicationController

  def index
    @balances = BalanceSheet.new DateTime.now
  end
  
end
