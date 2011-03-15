class TranscriptsController < ApplicationController
  
  def index
    if request.xhr?
      render :json => abstract_json_for_jqgrid('')
    end
  end

  def load
    @transcript = Transcript.new(params[:deal],
                                 DateTime.strptime(params[:start], '%m/%d/%Y'),
                                 DateTime.strptime(params[:stop], '%m/%d/%Y'))
  end

end
