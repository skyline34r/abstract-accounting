
class Transcript
  def initialize(deal, start, stop)
    @deal = deal
    @start = start
    @stop = stop
  end
  attr_reader :deal, :start, :stop
end
