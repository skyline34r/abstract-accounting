require "resource"
require "action_array"

#class StorehouseEntry
#  attr_reader :owner, :deal, :place, :product, :real_amount, :amount
#  def initialize(deal, place, amount, real_amount)
#    @amount = 0
#    @real_amount = 0
#    @product = nil
#    @owner = nil
#    @place = place
#    @amount = amount
#    @deal = deal
#    @real_amount = real_amount
#    if !deal.nil?
#      @owner = deal.entity
#      @product = Product.find_by_resource_id deal.give.id
#    end
#  end
#
#  def add_amount amount
#    @amount += amount
#  end
#
#  def add_real_amount real_amount
#    @real_amount += real_amount
#  end
#
#  def StorehouseEntry.state(deal, releases = nil)
#    return 0 if deal.nil? or deal.state.nil?
#    start_state = deal.state.amount
#    if releases.nil?
#      releases = StorehouseRelease.find_all_by_state StorehouseRelease::INWORK,
#          :include => {:deal => {:rules => :from}}
#    end
#    releases.each do |item|
#      if !item.deal.nil?
#        item.deal.rules.each do |rule|
#          if rule.from.id == deal.id
#            start_state -= rule.rate
#          end
#        end
#      end
#    end
#    start_state
#  end
#end
#
#class StorehouseWaybillEntry
#  attr_reader :product, :amount
#  def initialize(product, amount)
#    @product = product
#    @amount = amount
#  end
#end
#
#class StorehouseWaybill
#  attr_reader :waybill, :resources
#  def initialize(waybill)
#    @waybill = waybill
#    @resources = Array.new
#  end
#
#  def add_resource product, amount
#    @resources << StorehouseWaybillEntry.new(product, amount)
#  end
#end

class Storehouse
  attr_reader :owner_id, :place_id, :deal_id, :product_id, :real_amount, :exp_amount
  def owner
    Entity.find(self.owner_id)
  end
  def place
    Place.find(self.place_id)
  end
  def deal
    Deal.find(self.deal_id)
  end
  def product
    Product.find(self.product_id)
  end

  def initialize(attributes = nil)
    @owner_id = (!attributes.nil? && attributes.has_key?(:owner_id) ? attributes[:owner_id] : nil)
    @place_id = (!attributes.nil? && attributes.has_key?(:place_id) ? attributes[:place_id] : nil)
    @deal_id = (!attributes.nil? && attributes.has_key?(:deal_id) ? attributes[:deal_id] : nil)
    @product_id = (!attributes.nil? && attributes.has_key?(:product_id) ? attributes[:product_id] : nil)
    @real_amount = (!attributes.nil? && attributes.has_key?(:real_amount) ? attributes[:real_amount] : nil)
    @exp_amount = (!attributes.nil? && attributes.has_key?(:exp_amount) ? attributes[:exp_amount] : nil)
    #@entity = entity
    #@place = place
    #@waybills = nil
    #
    #unless without_fill
    #  #SELECT states.amount, sr_rules.id, SUM(CASE WHEN sr_rules.id IS NULL THEN 0.0 ELSE sr_rules.rate END) FROM states LEFT JOIN (%waybills%) AS rules ON rules.to_id = states.deal_id LEFT JOIN (%srs%) AS sr_rules ON sr_rules.from_id = states.deal_id WHERE states.paid IS NULL AND (rules.id IS NOT NULL OR sr_rules.id IS NOT NULL) GROUP BY states.id
    #  #wbs = Waybill.not_disabled.find_by_owner_and_place @entity, @place,
    #  #      :include => { :deal => { :rules => :to }}
    #  #releases = StorehouseRelease.find_all_by_owner_and_place_and_state @entity, @place,
    #  #      StorehouseRelease::INWORK, :include => {:deal => {:rules => :from}}
    #  #if !wbs.nil?
    #  #  inner = Hash.new
    #  #  wbs.each do |item|
    #  #    if !item.deal.nil?
    #  #      item.deal.rules.each do |rule|
    #  #        if !inner.has_key?(rule.to.id)
    #  #          amount = StorehouseEntry.state(rule.to, releases)
    #  #          if (real_amount and !rule.to.state.nil? and rule.to.state.amount > 0) or
    #  #              (!real_amount and amount > 0)
    #  #            self << StorehouseEntry.new(rule.to, item.place, amount)
    #  #          end
    #  #          inner[rule.to.id] = true
    #  #        end
    #  #      end
    #  #    end
    #  #  end
    #  #end
    #  #if !(entity.nil? or (!entity.nil? and place.nil?))
    #  #  sr_rules + " WHERE owner_id = #{entity.id} AND place_id = #{place.id}"
    #  #end
    #  #self.group_by_real_resource
    #end
  end

  def Storehouse.all(attributes = nil)
    check_amount = (!attributes.nil? && attributes.has_key?(:check_amount) ? attributes[:check_amount] : true)
    place = (!attributes.nil? && attributes.has_key?(:place) ? attributes[:place] : nil)
    entity = (!attributes.nil? && attributes.has_key?(:entity) ? attributes[:entity] : nil)
    where = ""
    amount_where = ""
    if !attributes.nil? and attributes.has_key?(:where)
      attributes[:where].each do |attr, value|
        if attr == 'product.resource.tag'
          where += where.empty? ? "WHERE " : " AND "
          where += "lower(CASE WHEN asset_reals.id IS NULL THEN assets.tag ELSE asset_reals.tag END)"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].to_s + "%'"
          end
        elsif attr == 'product.unit'
          where += where.empty? ? "WHERE " : " AND "
          where += "lower(products.unit)"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].to_s + "%'"
          end
        elsif attr == 'place.tag'
          where += where.empty? ? "WHERE " : " AND "
          where += "lower(places.tag)"
          if value.kind_of?(Hash)
            where += " LIKE '%" + value[:like].to_s + "%'"
          end
        elsif attr == 'exp_amount'
          amount_where += " AND warehouse.exp_amount"
          if value.kind_of?(Hash)
            amount_where += " LIKE '%" + value[:like].to_s + "%'"
          end
        elsif attr == 'real_amount'
          amount_where += " AND warehouse.real_amount"
          if value.kind_of?(Hash)
            amount_where += " LIKE '%" + value[:like].to_s + "%'"
          end
        end
      end
    end
    order = ""
    if !attributes.nil? and attributes.has_key?(:order)
      attributes[:order].each do |key, value|
        if key == 'product.resource.tag'
          order = "ORDER BY (CASE WHEN asset_reals.id IS NULL THEN assets.tag ELSE asset_reals.tag END) " + value.upcase
        elsif key == 'product.unit'
          order = "ORDER BY products.unit " + value.upcase
        elsif key == 'place.tag'
          order = "ORDER BY places.tag " + value.upcase
        elsif key == 'exp_amount'
          order = "ORDER BY exp_amount " + value.upcase
        elsif key == 'real_amount'
          order = "ORDER BY real_amount " + value.upcase
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
    states = "
    SELECT warehouse.* FROM
      (SELECT SUM(amount) as real_amount, ROUND(SUM(amount - exp_amount),2) as exp_amount,
             state_deal_id as deal_id, owner_id, place_id, products.id as product_id FROM (
        SELECT w_states.id as state_id, w_states.start as state_start, w_states.paid as state_paid,
               w_states.deal_id as state_deal_id, w_states.amount as amount, 0.0 as exp_amount,
               waybills.owner_id as owner_id, waybills.place_id as place_id FROM rules as w_rules
          INNER JOIN waybills ON waybills.deal_id = w_rules.deal_id
          INNER JOIN states as w_states ON w_states.deal_id = w_rules.to_id
        WHERE waybills.disable_deal_id IS NULL AND w_states.paid is NULL
        GROUP BY state_id, owner_id, place_id
        UNION
        SELECT sr_states.id as state_id, sr_states.start as state_start, sr_states.paid as state_paid,
               sr_states.deal_id as state_deal_id, 0.0 as amount, SUM(sr_rules.rate) as exp_amount,
               storehouse_releases.owner_id as owner_id, storehouse_releases.place_id as place_id FROM rules as sr_rules
          INNER JOIN storehouse_releases ON storehouse_releases.deal_id = sr_rules.deal_id
          INNER JOIN states as sr_states ON sr_states.deal_id = sr_rules.from_id
        WHERE storehouse_releases.state = 1 AND sr_states.paid IS NULL
        GROUP BY state_id, owner_id, place_id
      )
        INNER JOIN deals ON deals.id = deal_id
        INNER JOIN assets ON assets.id = deals.give_id
        INNER JOIN products ON products.resource_id = deals.give_id
        INNER JOIN places ON places.id = place_id
        LEFT JOIN asset_reals ON asset_reals.id = assets.real_id
      " + where + "
      GROUP BY (CASE WHEN asset_reals.id IS NULL THEN assets.id ELSE asset_reals.id END), owner_id, place_id " + order +
    ") as warehouse
    WHERE " + (check_amount ? "warehouse.real_amount > 0.0" : "warehouse.exp_amount > 0.0") + "
    " + ((entity.nil? or (!entity.nil? and place.nil?)) ? "" : "AND warehouse.owner_id = #{entity.id} AND warehouse.place_id = #{place.id}") +
        amount_where + limit
    warehouse = Array.new
    ActiveRecord::Base.connection.execute(states).each do |state|
      attrs = Hash.new
      state.each { |key, value| attrs[key.to_sym] = value if key.kind_of?(String) }
      warehouse << Storehouse.new(attrs)
    end
    warehouse
  end

  def Storehouse.shipment
    a = Asset.find_by_tag("Storehouse Shipment")
    if a.nil?
      a = Asset.new :tag => "Storehouse Shipment"
      return nil unless a.save
    end
    a
  end

  #def Storehouse.taskmaster entity, place
  #  resources = Hash.new
  #  sr = StorehouseRelease.find_all_by_to_id_and_place_id_and_state entity.id,
  #    place.id, StorehouseRelease::APPLIED
  #  sr.each do |release|
  #    release.deal.rules.each do |rule|
  #      if !resources.key?(rule.to.id)
  #        resources[rule.to.id] = rule.to.state.amount
  #      end
  #    end unless release.deal.nil? or release.deal.rules.nil?
  #  end unless sr.nil?
  #  s = Storehouse.new entity, place, true, true
  #  resources.each do |key, value|
  #    d = Deal.find(key)
  #    s << StorehouseEntry.new(d, s.place, value, d.state.amount)
  #  end
  #  s
  #end
  #
  #def Storehouse.taskmasters entity, place
  #  resources = Hash.new
  #  sr = StorehouseRelease.find_all_by_owner_and_place_and_state entity,
  #    place, StorehouseRelease::APPLIED
  #  sr.each do |release|
  #    release.deal.rules.each do |rule|
  #      if !resources.key?(rule.to.id)
  #        resources[rule.to.id] = rule.to.state.amount
  #      end
  #    end unless release.deal.nil? or release.deal.rules.nil?
  #  end unless sr.nil?
  #  s = Storehouse.new entity, place, true, true
  #  resources.each do |key, value|
  #    d = Deal.find(key)
  #    s << StorehouseEntry.new(d, s.place, value, d.state.amount)
  #  end
  #  s
  #end
  #
  #def waybills
  #  return @waybills if !@waybills.nil?
  #  waybills = Hash.new
  #  self.each do |sh_entry|
  #    amount = sh_entry.amount
  #    Waybill.not_disabled.order("created DESC").find_by_owner_and_place(@entity, @place).each do |waybill|
  #      waybill.resources.each do |resource|
  #        if sh_entry.product.id == resource.product.id or
  #            (!sh_entry.product.resource.real.nil? and !resource.product.resource.real.nil? and
  #              sh_entry.product.resource.real.id == resource.product.resource.real.id)
  #          unless waybills.key?(waybill.id)
  #            waybills[waybill.id] = StorehouseWaybill.new(waybill)
  #          end
  #          if amount <= resource.amount
  #            waybills[waybill.id].add_resource resource.product, amount
  #            amount = 0
  #          else
  #            waybills[waybill.id].add_resource resource.product, resource.amount
  #            amount -= resource.amount
  #          end
  #          break
  #        end
  #      end
  #      break if amount == 0
  #    end
  #  end
  #  @waybills = waybills.values
  #end
  #
  #def waybill_by_id id
  #  self.waybills.each do |item|
  #    if item.waybill.id == id
  #      return item
  #    end
  #  end
  #  nil
  #end
  #
  #def group_by_real_resource
  #  group = Hash.new
  #  origins = Array.new
  #  self.each do |item|
  #    unless item.product.resource.real.nil?
  #      rid = item.product.resource.real.id
  #      if group.has_key?(rid)
  #        if group[rid].has_key?(item.owner.id)
  #          group[rid][item.owner.id].add_amount item.amount
  #          group[rid][item.owner.id].add_real_amount item.real_amount
  #        else
  #          group[rid][item.owner.id] = item
  #        end
  #      else
  #        group[rid] = Hash.new
  #        group[rid][item.owner.id] = item
  #      end
  #    else
  #      origins << item
  #    end
  #  end
  #  self.clear
  #  origins.each do |item|
  #    self << item
  #  end
  #  group.each_value do |hash|
  #    hash.each_value do |value|
  #      self << value
  #    end
  #  end
  #end
end
