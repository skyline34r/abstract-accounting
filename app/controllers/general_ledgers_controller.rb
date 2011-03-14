require 'resource.rb'

class GeneralLedgersController < ApplicationController

  def index
    Money.class_exec {
      def tag
        return alpha_code
      end
    }
    @general_ledgers = GeneralLedger.new
  end

end
