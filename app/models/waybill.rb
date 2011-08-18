#validate vatin only for Russian Federation
class VatinValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:vatin] <<
      "Vatin is invalid. Valid count of numbers is 10 or 12" if
      record.vatin.length != 10 and record.vatin.length != 12
    record.errors[:vatin] << "VATIN is not numeric" if
      record.vatin.match(/\A\d+\Z/) == nil
    record.errors[:vatin] << "Invalid checksum" if !vatin?(record.vatin)
  end

  def vatin?(vatin)
    base_prefix = [3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8]
    valid = false
    if vatin.length == 10
      valid = check_sum vatin, base_prefix[2..10], vatin[-1].to_i
    elsif vatin.length == 12
      check_sum(vatin, base_prefix[1..10], vatin[-2].to_i) do
        valid = check_sum vatin, base_prefix, vatin[-1].to_i
      end
    end
    valid
  end

  def check_sum(vatin, prefix, sum)
    res = 0
    prefix.each_index do |index|
      res += vatin[index].to_i * prefix[index]
    end
    if (res % 11) % 10 == sum
      if block_given?
        yield
      else
        true
      end
    else
      false
    end
  end
end

class ResourcesValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:resources] <<
      "Resources must exist" if record.resources.empty?
    resources = Hash.new
    record.resources.each do |item|
      record.errors[:resources] <<
          "invalid" if item.product.nil? or item.product.invalid?
      record.errors[:resources] <<
          "invalid amount" if item.amount <= 0
      record.errors[:resources] <<
          "two identical resources" if resources.key?(item.product.resource.tag)
      resources[item.product.resource.tag] = true
    end
  end
end

class WaybillEntry
  attr_reader :product, :amount
  def initialize(product, amount)
    @product = product
    @amount = amount
  end

  def storehouse_deal entity
    return nil if entity.nil?
    storehouses =
      if self.product.id.nil? or self.product.resource.id.nil? or entity.id.nil?
        Array.new
      else
        Deal.find_all_by_give_and_take_and_entity(self.product.resource,
          self.product.resource, entity)
      end
    if storehouses.length == 1
      storehouses.first
    else
      Deal.new :entity => entity, :give => self.product.resource,
        :take => self.product.resource, :rate => 1.0, :isOffBalance => true,
        :tag => "storehouse entity: " + entity.tag + "; resource: " + self.product.resource.tag + ";"
    end
  end
end

class WaybillWithWarehouse
  attr_reader :has_in_the_warehouse
  def initialize(waybill_id, in_the_warehouse)
    @waybill_id = waybill_id
    @has_in_the_warehouse = in_the_warehouse
  end

  def waybill
    Waybill.find(@waybill_id)
  end
end

class Waybill < ActiveRecord::Base
  has_paper_trail

  #validations
  validates :document_id, :presence => true
  validates :owner_id, :presence => true
  validates :place_id, :presence => true
  validates :from_id, :presence => true
  validates :created, :presence => true
  
  validates_with VatinValidator, :if => "!vatin.nil? && !vatin.empty?"

  validates_with ResourcesValidator
  #associations
  belongs_to :owner, :class_name => 'Entity'
  belongs_to :place
  belongs_to :from, :class_name => 'Entity'
  belongs_to :deal
  belongs_to :disable_deal, :class_name => 'Deal'

  scope :not_disabled, where("waybills.disable_deal_id IS NULL")
  scope :disabled, where("waybills.disable_deal_id IS NOT NULL")
  scope :by_storekeeper, lambda { |owner = nil, place = nil|
    if !owner.nil? and !place.nil?
      where("waybills.owner_id = ? AND waybills.place_id = ?", owner.id, place.id)
    end
  }
  def Waybill.with_warehouse_state(attributes = nil)
    where = ""
    if !attributes.nil? and attributes.has_key?(:entity) and attributes.has_key?(:place) and
       !attributes[:entity].nil? and !attributes[:place].nil?
      where += " AND waybills.owner_id = " + attributes[:entity].id.to_s +
               " AND waybills.place_id = " + attributes[:place].id.to_s
    end
    order = ""
    if !attributes.nil? and attributes.has_key?(:sidx) and !attributes[:sidx].nil?
      case attributes[:sidx]
        when 'from'
          order = "ORDER BY CASE WHEN from_reals.id IS NULL THEN from_entities.tag ELSE from_reals.tag END" + " " + attributes[:sord].upcase
        when "owner"
          order = "ORDER BY CASE WHEN owner_reals.id IS NULL THEN owner_entities.tag ELSE owner_reals.tag END" + " " + attributes[:sord].upcase
        when "place"
          order = "ORDER BY places.tag" + " " + attributes[:sord].upcase
        else
          order = "ORDER BY waybills." + attributes[:sidx] + " " + attributes[:sord].upcase
      end
    end
    if !attributes.nil? and attributes.has_key?(:search)
      attributes[:search].each do |attr, value|
        if value.kind_of?(Hash)
          case attr
            when :owner
              where += " AND lower(CASE WHEN owner_reals.id IS NULL THEN owner_entities.tag ELSE owner_reals.tag END)"
            when :from
              where += " AND lower(CASE WHEN from_reals.id IS NULL THEN from_entities.tag ELSE from_reals.tag END)"
            when :document_id
              where += " AND waybills.document_id"
            when :vatin
              where += " AND waybills.vatin"
            when :created
              where += " AND waybills.created"
            when :place
              where += " AND lower(places.tag)"
          end
          where += " LIKE lower('%" + value[:like].to_s + "%')"
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
      limit = " LIMIT " + per_page.to_s + " OFFSET " + ((page- 1) * per_page).to_s
    end
    sql = "
    SELECT warehouse.id, SUM(CASE WHEN warehouse.sec_rate < warehouse.amount THEN 1 ELSE 0 END) as in_the_warehouse FROM (
SELECT id, SUM(rate) as rate, SUM(amount) as amount, SUM(sec_rate) as sec_rate FROM (
SELECT waybills.id as id, assets.id as asset_id, rules.rate as rate,
       CASE WHEN states.id IS NULL THEN 0.0 ELSE states.amount END as amount,
       SUM(CASE WHEN sec_waybills.id IS NULL THEN 0.0 ELSE sec_rules.rate END) as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
  INNER JOIN entities AS from_entities ON from_entities.id = waybills.from_id
  INNER JOIN entities AS owner_entities ON owner_entities.id = waybills.owner_id
  INNER JOIN places ON places.id = waybills.place_id
  LEFT JOIN entity_reals AS from_reals ON from_reals.id = from_entities.real_id
  LEFT JOIN entity_reals AS owner_reals ON owner_reals.id = owner_entities.real_id
  LEFT JOIN states ON states.deal_id = rules.to_id AND states.paid IS NULL
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN asset_reals ON asset_reals.id = assets.real_id
  LEFT JOIN assets AS sec_assets ON sec_assets.real_id = asset_reals.id AND sec_assets.id != assets.id
  LEFT JOIN deals AS sec_deals ON sec_deals.give_id = sec_assets.id
  LEFT JOIN rules AS sec_rules ON sec_rules.to_id = sec_deals.id AND sec_rules.id != rules.id
  LEFT JOIN waybills AS sec_waybills ON sec_waybills.deal_id = sec_rules.deal_id AND sec_waybills.disable_deal_id IS NULL
                                          AND (sec_waybills.created > waybills.created OR (sec_waybills.created = waybills.created AND sec_waybills.id > waybills.id)) AND sec_waybills.owner_id = waybills.owner_id
                                          AND sec_waybills.place_id = waybills.place_id
WHERE waybills.disable_deal_id IS NULL" + where + "
GROUP BY waybills.id, rules.to_id
UNION
SELECT waybills.id as id, assets.id as asset_id, 0.0 as rate, 0.0 as amount, SUM(CASE WHEN new_ws.id IS NULL THEN 0.0 ELSE new_rs.rate END) as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
INNER JOIN entities AS from_entities ON from_entities.id = waybills.from_id
INNER JOIN entities AS owner_entities ON owner_entities.id = waybills.owner_id
INNER JOIN places ON places.id = waybills.place_id
LEFT JOIN entity_reals AS from_reals ON from_reals.id = from_entities.real_id
LEFT JOIN entity_reals AS owner_reals ON owner_reals.id = owner_entities.real_id
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN rules AS new_rs ON new_rs.to_id = rules.to_id AND new_rs.id != rules.id
  LEFT JOIN waybills AS new_ws ON new_ws.deal_id = new_rs.deal_id AND new_ws.disable_deal_id IS NULL
                                  AND (new_ws.created > waybills.created OR (new_ws.created = waybills.created AND new_ws.id > waybills.id)) AND new_ws.owner_id = waybills.owner_id
                                  AND new_ws.place_id = waybills.place_id
WHERE waybills.disable_deal_id IS NULL AND new_ws.id IS NOT NULL" + where + "
GROUP BY waybills.id, rules.id
UNION
SELECT waybills.id as id, assets.id as asset_id, 0.0 as rate,
       CASE WHEN states.id IS NULL THEN 0.0 ELSE states.amount END as amount, 0.0 as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
INNER JOIN entities AS from_entities ON from_entities.id = waybills.from_id
INNER JOIN entities AS owner_entities ON owner_entities.id = waybills.owner_id
INNER JOIN places ON places.id = waybills.place_id
LEFT JOIN entity_reals AS from_reals ON from_reals.id = from_entities.real_id
LEFT JOIN entity_reals AS owner_reals ON owner_reals.id = owner_entities.real_id
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN asset_reals ON asset_reals.id = assets.real_id
  LEFT JOIN assets AS sec_assets ON sec_assets.real_id = asset_reals.id
  LEFT JOIN deals AS sec_deals ON sec_deals.give_id = sec_assets.id AND sec_deals.id != deals.id
  LEFT JOIN rules AS sec_rules ON sec_rules.to_id = sec_deals.id AND sec_rules.id != rules.id
  LEFT JOIN waybills AS sec_waybills ON sec_waybills.deal_id = sec_rules.deal_id AND sec_waybills.disable_deal_id IS NULL
                                          AND sec_waybills.owner_id = waybills.owner_id AND sec_waybills.place_id = waybills.place_id
  LEFT JOIN states ON states.deal_id = sec_rules.to_id AND states.paid IS NULL
WHERE waybills.disable_deal_id IS NULL AND sec_waybills.id IS NOT NULL" + where + "
GROUP BY waybills.id, sec_deals.id
UNION
SELECT waybills.id as id, assets.id as asset_id, 0.0 as rate, -SUM(CASE WHEN sr.id IS NULL THEN 0.0 ELSE sec_rules.rate END) as amount, 0.0 as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
INNER JOIN entities AS from_entities ON from_entities.id = waybills.from_id
INNER JOIN entities AS owner_entities ON owner_entities.id = waybills.owner_id
INNER JOIN places ON places.id = waybills.place_id
LEFT JOIN entity_reals AS from_reals ON from_reals.id = from_entities.real_id
LEFT JOIN entity_reals AS owner_reals ON owner_reals.id = owner_entities.real_id
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN asset_reals ON asset_reals.id = assets.real_id
  LEFT JOIN assets AS sec_assets ON sec_assets.real_id = asset_reals.id
  LEFT JOIN deals AS sec_deals ON sec_deals.give_id = sec_assets.id
  LEFT JOIN rules AS sec_rules ON sec_rules.from_id = sec_deals.id
  LEFT JOIN storehouse_releases AS sr ON sr.deal_id = sec_rules.deal_id
                                          AND sr.created >= waybills.created AND sr.owner_id = waybills.owner_id
                                          AND sr.place_id = waybills.place_id
WHERE waybills.disable_deal_id IS NULL AND sr.id IS NOT NULL" + where + "
GROUP BY waybills.id, rules.to_id
UNION
SELECT waybills.id as id, assets.id as asset_id, 0.0 as rate, -SUM(new_rs.rate) as amount, 0.0 as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
INNER JOIN entities AS from_entities ON from_entities.id = waybills.from_id
INNER JOIN entities AS owner_entities ON owner_entities.id = waybills.owner_id
INNER JOIN places ON places.id = waybills.place_id
LEFT JOIN entity_reals AS from_reals ON from_reals.id = from_entities.real_id
LEFT JOIN entity_reals AS owner_reals ON owner_reals.id = owner_entities.real_id
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN rules AS new_rs ON new_rs.from_id = rules.to_id
  INNER JOIN storehouse_releases AS sr ON sr.deal_id = new_rs.deal_id AND sr.state = 1
                                          AND sr.created >= waybills.created AND sr.owner_id = waybills.owner_id
                                          AND sr.place_id = waybills.place_id
WHERE waybills.disable_deal_id IS NULL" + where + "
GROUP BY waybills.id, rules.to_id)
GROUP BY id, asset_id) as warehouse
INNER JOIN waybills ON waybills.id = warehouse.id
INNER JOIN entities AS from_entities ON from_entities.id = waybills.from_id
INNER JOIN entities AS owner_entities ON owner_entities.id = waybills.owner_id
INNER JOIN places ON places.id = waybills.place_id
LEFT JOIN entity_reals AS from_reals ON from_reals.id = from_entities.real_id
LEFT JOIN entity_reals AS owner_reals ON owner_reals.id = owner_entities.real_id
GROUP BY warehouse.id
" + order + "
" + limit + "
    "
    waybills = Array.new
    ActiveRecord::Base.connection.execute(sql).each do |item|
      waybills << WaybillWithWarehouse.new(item["id"], (item["in_the_warehouse"] > 0 ? true : false))
    end
    waybills
  end
  def Waybill.in_warehouse(attributes = nil)
    where = ""
    if !attributes.nil? and attributes.has_key?(:entity) and attributes.has_key?(:place) and
       !attributes[:entity].nil? and !attributes[:place].nil?
      where += " AND waybills.owner_id = " + attributes[:entity].id.to_s +
               " AND waybills.place_id = " + attributes[:place].id.to_s
    end
    order = ""
    if !attributes.nil? and attributes.has_key?(:sidx) and !attributes[:sidx].nil?
      case attributes[:sidx]
        when 'from'
          order = "ORDER BY CASE WHEN from_reals.id IS NULL THEN from_entities.tag ELSE from_reals.tag END" + " " + attributes[:sord].upcase
        when "owner"
          order = "ORDER BY CASE WHEN owner_reals.id IS NULL THEN owner_entities.tag ELSE owner_reals.tag END" + " " + attributes[:sord].upcase
        when "place"
          order = "ORDER BY places.tag" + " " + attributes[:sord].upcase
        else
          order = "ORDER BY waybills." + attributes[:sidx] + " " + attributes[:sord].upcase
      end
    end
    if !attributes.nil? and attributes.has_key?(:search)
      attributes[:search].each do |attr, value|
        if value.kind_of?(Hash)
          case attr
            when :owner
              where += " AND lower(CASE WHEN owner_reals.id IS NULL THEN owner_entities.tag ELSE owner_reals.tag END)"
            when :from
              where += " AND lower(CASE WHEN from_reals.id IS NULL THEN from_entities.tag ELSE from_reals.tag END)"
            when :document_id
              where += " AND waybills.document_id"
            when :vatin
              where += " AND waybills.vatin"
            when :created
              where += " AND waybills.created"
            when :place
              where += " AND lower(places.tag)"
          end
          where += " LIKE lower('%" + value[:like].to_s + "%')"
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
      limit = " LIMIT " + per_page.to_s + " OFFSET " + ((page- 1) * per_page).to_s
    end
    sql = "
    SELECT warehouse.id FROM (
SELECT id, SUM(rate) as rate, SUM(amount) as amount, SUM(sec_rate) as sec_rate FROM (
SELECT waybills.id as id, assets.id as asset_id, rules.rate as rate, states.amount as amount, SUM(CASE WHEN sec_waybills.id IS NULL THEN 0.0 ELSE sec_rules.rate END) as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
INNER JOIN entities AS from_entities ON from_entities.id = waybills.from_id
INNER JOIN entities AS owner_entities ON owner_entities.id = waybills.owner_id
INNER JOIN places ON places.id = waybills.place_id
LEFT JOIN entity_reals AS from_reals ON from_reals.id = from_entities.real_id
LEFT JOIN entity_reals AS owner_reals ON owner_reals.id = owner_entities.real_id
  INNER JOIN states ON states.deal_id = rules.to_id AND states.paid IS NULL
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN asset_reals ON asset_reals.id = assets.real_id
  LEFT JOIN assets AS sec_assets ON sec_assets.real_id = asset_reals.id AND sec_assets.id != assets.id
  LEFT JOIN deals AS sec_deals ON sec_deals.give_id = sec_assets.id
  LEFT JOIN rules AS sec_rules ON sec_rules.to_id = sec_deals.id AND sec_rules.id != rules.id
  LEFT JOIN waybills AS sec_waybills ON sec_waybills.deal_id = sec_rules.deal_id AND sec_waybills.disable_deal_id IS NULL
                                          AND (sec_waybills.created > waybills.created OR (sec_waybills.created = waybills.created AND sec_waybills.id > waybills.id)) AND sec_waybills.owner_id = waybills.owner_id
                                          AND sec_waybills.place_id = waybills.place_id
WHERE waybills.disable_deal_id IS NULL" + where + "
GROUP BY waybills.id, rules.to_id
UNION
SELECT waybills.id as id, assets.id as asset_id, 0.0 as rate, 0.0 as amount, SUM(CASE WHEN new_ws.id IS NULL THEN 0.0 ELSE new_rs.rate END) as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
INNER JOIN entities AS from_entities ON from_entities.id = waybills.from_id
INNER JOIN entities AS owner_entities ON owner_entities.id = waybills.owner_id
INNER JOIN places ON places.id = waybills.place_id
LEFT JOIN entity_reals AS from_reals ON from_reals.id = from_entities.real_id
LEFT JOIN entity_reals AS owner_reals ON owner_reals.id = owner_entities.real_id
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN rules AS new_rs ON new_rs.to_id = rules.to_id AND new_rs.id != rules.id
  LEFT JOIN waybills AS new_ws ON new_ws.deal_id = new_rs.deal_id AND new_ws.disable_deal_id IS NULL
                                  AND (new_ws.created > waybills.created OR (new_ws.created = waybills.created AND new_ws.id > waybills.id)) AND new_ws.owner_id = waybills.owner_id
                                  AND new_ws.place_id = waybills.place_id
WHERE waybills.disable_deal_id IS NULL AND new_ws.id IS NOT NULL" + where + "
GROUP BY waybills.id, rules.id
UNION
SELECT waybills.id as id, assets.id as asset_id, 0.0 as rate,
       CASE WHEN states.id IS NULL THEN 0.0 ELSE states.amount END as amount, 0.0 as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
  INNER JOIN entities AS from_entities ON from_entities.id = waybills.from_id
  INNER JOIN entities AS owner_entities ON owner_entities.id = waybills.owner_id
  INNER JOIN places ON places.id = waybills.place_id
  LEFT JOIN entity_reals AS from_reals ON from_reals.id = from_entities.real_id
  LEFT JOIN entity_reals AS owner_reals ON owner_reals.id = owner_entities.real_id
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN asset_reals ON asset_reals.id = assets.real_id
  LEFT JOIN assets AS sec_assets ON sec_assets.real_id = asset_reals.id
  LEFT JOIN deals AS sec_deals ON sec_deals.give_id = sec_assets.id AND sec_deals.id != deals.id
  LEFT JOIN rules AS sec_rules ON sec_rules.to_id = sec_deals.id AND sec_rules.id != rules.id
  LEFT JOIN waybills AS sec_waybills ON sec_waybills.deal_id = sec_rules.deal_id AND sec_waybills.disable_deal_id IS NULL
                                          AND sec_waybills.owner_id = waybills.owner_id AND sec_waybills.place_id = waybills.place_id
  LEFT JOIN states ON states.deal_id = sec_rules.to_id AND states.paid IS NULL
WHERE waybills.disable_deal_id IS NULL AND sec_waybills.id IS NOT NULL" + where + "
GROUP BY waybills.id, sec_deals.id
UNION
SELECT waybills.id as id, assets.id as asset_id, 0.0 as rate, -SUM(CASE WHEN sr.id IS NULL THEN 0.0 ELSE sec_rules.rate END) as amount, 0.0 as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
INNER JOIN entities AS from_entities ON from_entities.id = waybills.from_id
INNER JOIN entities AS owner_entities ON owner_entities.id = waybills.owner_id
INNER JOIN places ON places.id = waybills.place_id
LEFT JOIN entity_reals AS from_reals ON from_reals.id = from_entities.real_id
LEFT JOIN entity_reals AS owner_reals ON owner_reals.id = owner_entities.real_id
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN asset_reals ON asset_reals.id = assets.real_id
  LEFT JOIN assets AS sec_assets ON sec_assets.real_id = asset_reals.id
  LEFT JOIN deals AS sec_deals ON sec_deals.give_id = sec_assets.id
  LEFT JOIN rules AS sec_rules ON sec_rules.from_id = sec_deals.id
  LEFT JOIN storehouse_releases AS sr ON sr.deal_id = sec_rules.deal_id
                                          AND sr.created >= waybills.created AND sr.owner_id = waybills.owner_id
                                          AND sr.place_id = waybills.place_id
WHERE waybills.disable_deal_id IS NULL AND sr.id IS NOT NULL" + where + "
GROUP BY waybills.id, rules.to_id
UNION
SELECT waybills.id as id, assets.id as asset_id, 0.0 as rate, -SUM(new_rs.rate) as amount, 0.0 as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
INNER JOIN entities AS from_entities ON from_entities.id = waybills.from_id
INNER JOIN entities AS owner_entities ON owner_entities.id = waybills.owner_id
INNER JOIN places ON places.id = waybills.place_id
LEFT JOIN entity_reals AS from_reals ON from_reals.id = from_entities.real_id
LEFT JOIN entity_reals AS owner_reals ON owner_reals.id = owner_entities.real_id
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN rules AS new_rs ON new_rs.from_id = rules.to_id
  INNER JOIN storehouse_releases AS sr ON sr.deal_id = new_rs.deal_id AND sr.state = 1
                                          AND sr.created >= waybills.created AND sr.owner_id = waybills.owner_id
                                          AND sr.place_id = waybills.place_id
WHERE waybills.disable_deal_id IS NULL" + where + "
GROUP BY waybills.id, rules.to_id)
GROUP BY id, asset_id) as warehouse
INNER JOIN waybills ON waybills.id = warehouse.id
INNER JOIN entities AS from_entities ON from_entities.id = waybills.from_id
INNER JOIN entities AS owner_entities ON owner_entities.id = waybills.owner_id
INNER JOIN places ON places.id = waybills.place_id
LEFT JOIN entity_reals AS from_reals ON from_reals.id = from_entities.real_id
LEFT JOIN entity_reals AS owner_reals ON owner_reals.id = owner_entities.real_id
WHERE warehouse.sec_rate < warehouse.amount
GROUP BY warehouse.id
" + order + "
" + limit + "
    "
    waybills = Array.new
    ActiveRecord::Base.connection.execute(sql).each do |item|
      waybills << Waybill.find(item["id"])
    end
    waybills
  end

  alias_method :original_from=, :from=
  alias_method :original_from, :from
  def from=(entity)
    if !entity.nil?
      if entity.instance_of?(Entity)
        self.original_from = entity
        if entity.new_record?
          self.from_id = -1
        else
          self.from_id = entity.id
        end
      else
        a = entity.to_s
        if !Entity.find_by_tag_case_insensitive(a).nil?
          self.original_from = Entity.find_by_tag_case_insensitive(a)
          self.from_id = self.original_from.id
        else
          self.original_from = Entity.new(:tag => a)
          self.from_id = -1
        end
      end
    end
  end

  def from
    if self.original_from.nil? and !self.from_id.nil? and self.from_id > -1
      self.original_from = Entity.find(self.from_id)
    end
    self.original_from
  end

  def add_resource name, unit, amount
    prod = Product.find_by_resource_tag(name)
    if prod.nil?
      prod = Product.new :resource => name, :unit => unit
    end
    @entries << WaybillEntry.new(prod, amount)
  end

  def resources
    if @entries.empty? and !self.deal.nil?
      self.deal.rules.each do |item|
        @entries << WaybillEntry.new(Product.find_by_resource_id(item.from.take), item.rate)
      end
    end
    @entries
  end

  def warehouse_resources
    resources = Array.new
    ActiveRecord::Base.connection.execute(
    "
    SELECT products.id as product_id, SUM(resources.rate) as rate, SUM(resources.amount) - SUM(resources.sec_rate) as warehouse_state FROM (
SELECT waybills.id as id, assets.id as asset_id, rules.rate as rate, states.amount as amount, SUM(CASE WHEN sec_waybills.id IS NULL THEN 0.0 ELSE sec_rules.rate END) as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
  INNER JOIN states ON states.deal_id = rules.to_id AND states.paid IS NULL
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN asset_reals ON asset_reals.id = assets.real_id
  LEFT JOIN assets AS sec_assets ON sec_assets.real_id = asset_reals.id AND sec_assets.id != assets.id
  LEFT JOIN deals AS sec_deals ON sec_deals.give_id = sec_assets.id
  LEFT JOIN rules AS sec_rules ON sec_rules.to_id = sec_deals.id AND sec_rules.id != rules.id
  LEFT JOIN waybills AS sec_waybills ON sec_waybills.deal_id = sec_rules.deal_id AND sec_waybills.disable_deal_id IS NULL
                                          AND (sec_waybills.created > waybills.created OR (sec_waybills.created = waybills.created AND sec_waybills.id > waybills.id)) AND sec_waybills.owner_id = waybills.owner_id
                                          AND sec_waybills.place_id = waybills.place_id
WHERE waybills.disable_deal_id IS NULL AND waybills.id = " + self.id.to_s + "
GROUP BY waybills.id, rules.to_id
UNION
SELECT waybills.id as id, assets.id as asset_id, 0.0 as rate, 0.0 as amount, SUM(CASE WHEN new_ws.id IS NULL THEN 0.0 ELSE new_rs.rate END) as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN rules AS new_rs ON new_rs.to_id = rules.to_id AND new_rs.id != rules.id
  LEFT JOIN waybills AS new_ws ON new_ws.deal_id = new_rs.deal_id AND new_ws.disable_deal_id IS NULL
                                  AND (new_ws.created > waybills.created OR (new_ws.created = waybills.created AND new_ws.id > waybills.id)) AND new_ws.owner_id = waybills.owner_id
                                  AND new_ws.place_id = waybills.place_id
WHERE waybills.disable_deal_id IS NULL AND new_ws.id IS NOT NULL AND waybills.id = " + self.id.to_s + "
GROUP BY waybills.id, rules.id
UNION
SELECT waybills.id as id, assets.id as asset_id, 0.0 as rate, states.amount as amount, 0.0 as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN asset_reals ON asset_reals.id = assets.real_id
  LEFT JOIN assets AS sec_assets ON sec_assets.real_id = asset_reals.id
  LEFT JOIN deals AS sec_deals ON sec_deals.give_id = sec_assets.id AND sec_deals.id != deals.id
  LEFT JOIN rules AS sec_rules ON sec_rules.to_id = sec_deals.id AND sec_rules.id != rules.id
  LEFT JOIN waybills AS sec_waybills ON sec_waybills.deal_id = sec_rules.deal_id AND sec_waybills.disable_deal_id IS NULL
                                          AND sec_waybills.owner_id = waybills.owner_id AND sec_waybills.place_id = waybills.place_id
  LEFT JOIN states ON states.deal_id = sec_rules.to_id AND states.paid IS NULL
WHERE waybills.disable_deal_id IS NULL AND sec_waybills.id IS NOT NULL AND waybills.id = " + self.id.to_s + "
GROUP BY waybills.id, sec_deals.id
UNION
SELECT waybills.id as id, assets.id as asset_id, 0.0 as rate, -SUM(CASE WHEN sr.id IS NULL THEN 0.0 ELSE sec_rules.rate END) as amount, 0.0 as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN asset_reals ON asset_reals.id = assets.real_id
  LEFT JOIN assets AS sec_assets ON sec_assets.real_id = asset_reals.id
  LEFT JOIN deals AS sec_deals ON sec_deals.give_id = sec_assets.id
  LEFT JOIN rules AS sec_rules ON sec_rules.from_id = sec_deals.id
  LEFT JOIN storehouse_releases AS sr ON sr.deal_id = sec_rules.deal_id
                                          AND sr.created >= waybills.created AND sr.owner_id = waybills.owner_id
                                          AND sr.place_id = waybills.place_id
WHERE waybills.disable_deal_id IS NULL AND sr.id IS NOT NULL AND waybills.id = " + self.id.to_s + "
GROUP BY waybills.id, rules.to_id
UNION
SELECT waybills.id as id, assets.id as asset_id, 0.0 as rate, -SUM(new_rs.rate) as amount, 0.0 as sec_rate FROM waybills
  LEFT JOIN rules ON rules.deal_id = waybills.deal_id
  INNER JOIN deals ON deals.id = rules.to_id
  INNER JOIN assets ON assets.id = deals.give_id
  LEFT JOIN rules AS new_rs ON new_rs.from_id = rules.to_id
  INNER JOIN storehouse_releases AS sr ON sr.deal_id = new_rs.deal_id AND sr.state = 1
                                          AND sr.created >= waybills.created AND sr.owner_id = waybills.owner_id
                                          AND sr.place_id = waybills.place_id
WHERE waybills.disable_deal_id IS NULL AND waybills.id = " + self.id.to_s + "
GROUP BY waybills.id, rules.to_id) as resources
INNER JOIN products ON products.resource_id = resources.asset_id
GROUP BY resources.id, resources.asset_id
    "
    ).each do |item|
      amount = 0
      unless item["warehouse_state"] <= 0
        if item["warehouse_state"] >= item["rate"]
          amount = item["rate"]
        else
          amount = item["warehouse_state"]
        end
      end
      resources <<
          WaybillEntry.new(Product.find(item["product_id"]), amount) unless amount.zero?
    end
    resources
  end

  def disable arg_comment
    self.errors[:comment] << "mustn't be empty'" if arg_comment.nil? or arg_comment.empty?
    self.errors[:disable] << "Record already disabled" unless self.disable_deal.nil?
    return false unless self.errors.empty?
    self.comment = arg_comment
    self.save
  end

  after_initialize :waybill_initialize
  before_save :waybill_before_save

  private
  def waybill_initialize
    @entries = Array.new
  end

  def waybill_before_save
    if self.new_record?
      if self.from_id == -1
        return false unless self.from.save
        self.from_id = self.from.id
      end
      shipment = Storehouse.shipment
      self.deal = Deal.new :tag => "Waybill shipment #" + (Waybill.last.nil? ? 0 : Waybill.last.id).to_s,
        :rate => 1.0, :entity => self.owner, :give => shipment,
        :take => shipment, :isOffBalance => true
      return false unless self.deal.save
      @entries.each_with_index do |item, idx|
        if item.product.new_record?
          return false unless item.product.save
        end
        fromItem = item.storehouse_deal self.from
        return false if fromItem.nil? or !fromItem.save
        ownerItem = item.storehouse_deal self.owner
        return false if ownerItem.nil? or !ownerItem.save

        return false if self.deal.rules.create(:tag => self.deal.tag + "; rule" + idx.to_s,
          :from => fromItem, :to => ownerItem, :fact_side => false,
          :change_side => true, :rate => item.amount).nil?
      end
      self.deal_id = self.deal.id
      dt_now = DateTime.now
      return false if !Fact.new(:amount => 1.0,
              :day => DateTime.civil(dt_now.year, dt_now.month, dt_now.day, 12, 0, 0),
              :from => nil,
              :to => self.deal,
              :resource => self.deal.give).save
    elsif self.comment_changed?
      shipment = Storehouse.shipment
      deal = Deal.new :tag => "Waybill disabled shipment #" + self.id.to_s,
          :rate => 1.0, :entity_id => self.owner_id, :give => shipment,
          :take => shipment, :isOffBalance => true
      return false unless deal.save
      idx = 0
      self.deal.rules.each do |rule|
        return false unless deal.rules.create(:tag => deal.tag + "; rule" + idx.to_s,
          :from_id => rule.to_id, :to_id => rule.from_id, :fact_side => false,
          :change_side => true, :rate => rule.rate)
        idx += 1
      end
      dt_now = DateTime.now
      self.disable_deal = deal
      return false unless Fact.new(:amount => 1.0,
              :day => DateTime.civil(dt_now.year, dt_now.month, dt_now.day, 12, 0, 0),
              :from => nil,
              :to => self.disable_deal,
              :resource => self.disable_deal.give).save
    else
      return false
    end
    true
  end
end
