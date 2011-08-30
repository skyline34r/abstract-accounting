
class GeneralLedger < Array
  attr_reader :current_page, :total_pages, :total_entries

  def initialize(attributes = nil)
    @current_page = (!attributes.nil? && attributes.has_key?(:current_page) ?
                      attributes[:current_page] : 0)
    @total_entries = (!attributes.nil? && attributes.has_key?(:total_entries) ?
                       attributes[:total_entries] : 0)
    @total_pages = (!attributes.nil? && attributes.has_key?(:total_pages) ?
                    attributes[:total_pages] : 0)
  end

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
        elsif attr == 'credit'
          where += where.empty? ? "WHERE " : " AND "
          where += "value"
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

    limit = ""
    if !attributes.nil? and attributes.has_key?(:page) and attributes.has_key?(:per_page)
      page = attributes[:page]
      per_page = attributes[:per_page]
      if page.kind_of?(String)
        page = page.to_i
      end
      if per_page.kind_of?(String)
        per_page = per_page.to_i
      end
      limit = " LIMIT " + per_page.to_s + " OFFSET " + ((page-1) * per_page).to_s
    end

    sql = "
    SELECT facts.id AS fact_id, IFNULL(txns.value, 0.0) AS value,
           IFNULL(money.alpha_code, IFNULL(asset_reals.tag, assets.tag)) AS resource_tag,
           IFNULL(txns.status, NULL) AS status, IFNULL(txns.earnings, 0.0) AS earnings
    FROM facts
    LEFT JOIN txns ON txns.fact_id == facts.id
    LEFT JOIN money ON money.id==facts.resource_id AND facts.resource_type == 'Money'
    LEFT JOIN assets ON assets.id==facts.resource_id AND facts.resource_type == 'Asset'
    LEFT JOIN asset_reals ON asset_reals.id==assets.real_id " + where + " " + order +
    " " + limit

    attrs = Hash.new
    attrs[:current_page] = attributes[:page].to_i if !attributes.nil? && attributes.has_key?(:page)
    attrs[:total_entries] = Fact.all.count
    total_pages = 0
    if !attributes.nil? && attributes.has_key?(:per_page) && (attributes[:per_page].to_i > 0)
      total_pages = attrs[:total_entries].to_i / attributes[:per_page].to_i
      if ((total_pages * attributes[:per_page].to_i) < attrs[:total_entries].to_i)
        total_pages += 1
      end
    end
    attrs[:total_pages] = total_pages

    txns = GeneralLedger.new(attrs)
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
