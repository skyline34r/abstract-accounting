
class GeneralLedger
  def GeneralLedger.find(attributes = nil)
    order = ""
    if !attributes.nil? and attributes.has_key?(:order)
      attributes[:order].each do |key, value|
        if key == 'fact.day'
          order = "ORDER BY facts.day COLLATE NOCASE " + value.upcase
        end
      end
    end

    sql = "
    SELECT facts.id AS fact_id, IFNULL(txns.value, 0.0) AS value,
           IFNULL(txns.status, NULL) AS status, IFNULL(txns.earnings, 0.0) AS earnings
    FROM facts
    LEFT JOIN txns ON txns.fact_id == facts.id " + order

    txns = Array.new
    ActiveRecord::Base.connection.execute(sql).each do |result|
      attrs = Hash.new
      result.each { |key, value| attrs[key.to_sym] = value if key.kind_of?(String) }
      txns << Txn.new(attrs)
    end
    txns
  end
end
