
class GeneralLedger
  def GeneralLedger.find(attributes = nil)
    where = ""
    if !attributes.nil? and attributes.has_key?(:where)
      attributes[:where].each do |attr, value|
        if attr == 'fact.day'
          where += where.empty? ? "WHERE " : " AND "
          where += "facts.day"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].downcase.to_s + "%'"
          end
        elsif attr == 'resource.tag'
          where += where.empty? ? "WHERE " : " AND "
          where += "lower(resource_tag)"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].downcase.to_s + "%'"
          end
        elsif attr == 'fact.amount'
          where += where.empty? ? "WHERE " : " AND "
          where += "facts.amount"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].downcase.to_s + "%'"
          end
        elsif attr == 'debit'
          where += where.empty? ? "WHERE " : " AND "
          where += "(value + earnings)"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].downcase.to_s + "%'"
          end
        end
      end
    end

    order = ""
    if !attributes.nil? and attributes.has_key?(:order)
      attributes[:order].each do |key, value|
        if key == 'fact.day'
          order = "ORDER BY facts.day COLLATE NOCASE " + value.upcase
        elsif key == 'resource.tag'
            order = "ORDER BY resource_tag COLLATE NOCASE " + value.upcase
        elsif key == 'fact.amount'
            order = "ORDER BY facts.amount COLLATE NOCASE " + value.upcase
        elsif key == 'debit'
            order = "ORDER BY (value + earnings) " + value.upcase
        elsif key == 'credit'
            order = "ORDER BY value " + value.upcase
        end
      end
    end

    sql = "
    SELECT facts.id AS fact_id, IFNULL(txns.value, 0.0) AS value,
           IFNULL(money.alpha_code, IFNULL(asset_reals.tag, assets.tag)) AS resource_tag,
           IFNULL(txns.status, NULL) AS status, IFNULL(txns.earnings, 0.0) AS earnings
    FROM facts
    LEFT JOIN txns ON txns.fact_id == facts.id
    LEFT JOIN money ON money.id==facts.resource_id AND facts.resource_type == 'Money'
    LEFT JOIN assets ON assets.id==facts.resource_id AND facts.resource_type == 'Asset'
    LEFT JOIN asset_reals ON asset_reals.id==assets.real_id " + where + " " + order

    txns = Array.new
    ActiveRecord::Base.connection.execute(sql).each do |result|
      attrs = Hash.new
      result.each { |key, value| attrs[key.to_sym] = value if key.kind_of?(String) }
      txns << Txn.new(:fact_id => attrs[:fact_id],
                      :value => attrs[:value],
                      :status => attrs[:status],
                      :earnings => attrs[:earnings])
    end
    txns
  end
end
