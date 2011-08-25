
class BalanceSheet
  attr_reader :day, :assets, :liabilities

  def initialize(attributes = nil)
    @day = (!attributes.nil? && attributes.has_key?(:day) ? attributes[:day] : DateTime.now)
    @balances = (!attributes.nil? && attributes.has_key?(:balances) ?
                 attributes[:balances] : nil)
    @assets = 0.0
    @liabilities = 0.0
    if !attributes.nil? && attributes.has_key?(:totals) ? attributes[:totals] : false
      sql = "
      SELECT sum(CASE WHEN side=='passive' THEN value ELSE 0.0 END) AS assets,
             sum(CASE WHEN side=='active' THEN value ELSE 0.0 END) AS liabilities
      FROM (
        SELECT link.id, states.side AS side, IFNULL(balances.value, 0.0) AS value
        FROM
          (SELECT deals.id AS id, deals.tag AS tag, states.start AS start
           FROM deals
           LEFT JOIN states ON states.deal_id==deals.id AND states.start <= '" + @day.to_s + "'
             AND (states.paid > '" + @day.to_s + "' OR states.paid IS NULL)
           WHERE states.start IS NOT NULL) AS link
        LEFT JOIN states ON link.id==states.deal_id AND states.start==link.start
        LEFT JOIN balances ON link.id==balances.deal_id AND balances.start==link.start
        UNION
        SELECT NULL, incomes.side AS side, incomes.value AS value
        FROM incomes
        WHERE start<='" + @day.to_s + "' AND (paid>'" + @day.to_s + "' OR paid IS NULL)
      )"
      ActiveRecord::Base.connection.execute(sql).each do |result|
        @assets += result['assets'] unless result['assets'].nil?
        @liabilities += result['liabilities'] unless result['liabilities'].nil?
      end
    end
  end

  def balances
    @balances
  end

  def BalanceSheet.find(attributes = nil)
    day = (!attributes.nil? && attributes.has_key?(:day) ? attributes[:day] : DateTime.now)

    where = ""
    if !attributes.nil? and attributes.has_key?(:where)
      attributes[:where].each do |attr, value|
        if attr == 'deal.tag'
          where += where.empty? ? "WHERE " : " AND "
          where += "lower(deal_tag)"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].downcase.to_s + "%'"
          end
        elsif attr == 'entity.tag'
          where += where.empty? ? "WHERE " : " AND "
          where += "lower(entity_tag)"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].downcase.to_s + "%'"
          end
        elsif attr == 'resource.tag'
          where += where.empty? ? "WHERE " : " AND "
          where += "lower(resource_tag)"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].downcase.to_s + "%'"
          end
        elsif attr == 'physical.debit'
          where += where.empty? ? "WHERE " : " AND "
          where += "CASE WHEN sheet.side=='active' THEN 0.0 ELSE sheet.amount END"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].to_s + "%'"
          end
        elsif attr == 'accounting.debit'
          where += where.empty? ? "WHERE " : " AND "
          where += "CASE WHEN sheet.side=='active' THEN 0.0 ELSE sheet.value END"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].to_s + "%'"
          end
        elsif attr == 'physical.credit'
          where += where.empty? ? "WHERE " : " AND "
          where += "CASE WHEN sheet.side=='passive' THEN 0.0 ELSE sheet.amount END"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].to_s + "%'"
          end
        elsif attr == 'accounting.credit'
          where += where.empty? ? "WHERE " : " AND "
          where += "CASE WHEN sheet.side=='passive' THEN 0.0 ELSE sheet.value END"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].to_s + "%'"
          end
        end
      end
    end

    order = ""
    if !attributes.nil? and attributes.has_key?(:order)
      attributes[:order].each do |key, value|
        if key == 'deal.tag'
          order = "ORDER BY deal_tag COLLATE NOCASE " + value.upcase
        elsif key == 'entity.tag'
          order = "ORDER BY entity_tag COLLATE NOCASE " + value.upcase
        elsif key == 'resource.tag'
          order = "ORDER BY resource_tag COLLATE NOCASE " + value.upcase
        elsif key == 'physical.debit'
          order = "ORDER BY CASE WHEN sheet.side=='active'
                     THEN 0.0 ELSE sheet.amount END " + value.upcase
        elsif key == 'accounting.debit'
          order = "ORDER BY CASE WHEN sheet.side=='active'
                     THEN 0.0 ELSE sheet.value END " + value.upcase
        elsif key == 'physical.credit'
          order = "ORDER BY CASE WHEN sheet.side=='passive'
                     THEN 0.0 ELSE sheet.amount END " + value.upcase
        elsif key == 'accounting.credit'
          order = "ORDER BY CASE WHEN sheet.side=='passive'
                     THEN 0.0 ELSE sheet.value END " + value.upcase
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
    SELECT * FROM (
    SELECT states.id AS id, link.id AS deal_id, link.tag AS deal_tag,
           IFNULL(entity_reals.tag, entities.tag) AS entity_tag,
           IFNULL(money.alpha_code, IFNULL(asset_reals.tag, assets.tag)) AS resource_tag,
           states.side AS side, states.amount AS amount,
           IFNULL(balances.value, 0.0) AS value, states.start AS start
    FROM
      (SELECT deals.id AS id, deals.tag AS tag, deals.rate AS rate,
              deals.entity_id AS entity_id, deals.give_type AS give_type,
              deals.give_id AS give_id, deals.take_type AS take_type,
              deals.take_id AS take_id, states.start AS start
       FROM deals
       LEFT JOIN states ON states.deal_id==deals.id AND
         states.start <= '" + day.to_s + "' AND (states.paid > '" + day.to_s + "'
         OR states.paid IS NULL) WHERE states.start IS NOT NULL)
    AS link
    LEFT JOIN states ON link.id=states.deal_id AND states.start=link.start
    LEFT JOIN balances ON link.id=balances.deal_id AND balances.start=link.start
    LEFT JOIN entities ON entities.id==link.entity_id
    LEFT JOIN entity_reals ON entity_reals.id==entities.real_id
    LEFT JOIN money ON money.id==link.give_id AND link.give_type == 'Money'
    LEFT JOIN assets ON assets.id==link.give_id AND link.give_type == 'Asset'
    LEFT JOIN asset_reals ON asset_reals.id==assets.real_id
    UNION
    SELECT id, NULL, '" + I18n.t('activerecord.data.deal_income.tag_value') + "',
           '', '', incomes.side AS side, NULL, incomes.value AS value,
           incomes.start AS start
    FROM incomes
    WHERE start<='" + day.to_s + "' AND (paid>'" + day.to_s + "' OR paid IS NULL)
    ) AS sheet " + where + " " + order + " " + limit

    balances = Array.new
    ActiveRecord::Base.connection.execute(sql).each do |result|
      attrs = Hash.new
      result.each { |key, value| attrs[key.to_sym] = value if key.kind_of?(String) }
      if attrs[:deal_id].nil? and attrs[:amount].nil?
        balances << Income.new(:side => attrs[:side],
                               :value => attrs[:value],
                               :start => attrs[:start])
      else
        balances << Balance.new(:deal_id => attrs[:deal_id],
                                :side => attrs[:side],
                                :amount => attrs[:amount],
                                :value => attrs[:value],
                                :start => attrs[:start])
      end
    end
    BalanceSheet.new(:day => day, :balances => balances)
  end
end
