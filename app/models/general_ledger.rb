
class GeneralLedger < Array
  def initialize
    Fact.all.each do |item|
      self << (item.txn.nil? ? Txn.new(:fact => item, :value => 0, :earnings => 0) : item.txn)
    end
  end
end
