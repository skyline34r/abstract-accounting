
class GeneralLedger < Array
  def initialize
    Txn.all.each { |i| self << i }
  end
end
