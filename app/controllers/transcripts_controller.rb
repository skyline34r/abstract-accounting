class TranscriptsController < ApplicationController
  
  def index
  end

  def load
    @transcript = Transcript.new(params[:deal],
                                 DateTime.strptime(params[:start], '%m/%d/%Y'),
                                 DateTime.strptime(params[:stop], '%m/%d/%Y'))
  end

end
