
class GeneralLedger < Array
  def initialize
    sql = "
    SELECT facts.id AS fact_id, IFNULL(txns.value, 0.0) AS value,
           IFNULL(txns.status, NULL) AS status, IFNULL(txns.earnings, 0.0) AS earnings
    FROM facts
    LEFT JOIN txns ON txns.fact_id == facts.id"

    ActiveRecord::Base.connection.execute(sql).each do |result|
      attrs = Hash.new
      result.each { |key, value| attrs[key.to_sym] = value if key.kind_of?(String) }
      self << Txn.new(attrs)
    end
  end
end
