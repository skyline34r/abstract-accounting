require "resource"
require "action_array"

class StorehouseEntry
  attr_reader :owner, :deal, :place, :product, :real_amount, :amount
  def initialize(deal, place, amount)
    @amount = 0
    @real_amount = 0
    @product = nil
    @owner = nil
    @place = place
    @amount = amount
    @deal = deal
    if !deal.nil?
      @owner = deal.entity
      @product = Product.find_by_resource_id deal.give.id
      @real_amount = deal.state.amount
    end
  end

  def add_amount amount
    @amount += amount
  end

  def add_real_amount real_amount
    @real_amount += real_amount
  end

  def StorehouseEntry.state(deal, releases = nil)
    return 0 if deal.nil? or deal.state.nil?
    start_state = deal.state.amount
    if releases.nil?
      releases = StorehouseRelease.find_all_by_state StorehouseRelease::INWORK,
          :include => {:deal => {:rules => :from}}
    end
    releases.each do |item|
      if !item.deal.nil?
        item.deal.rules.each do |rule|
          if rule.from.id == deal.id
            start_state -= rule.rate
          end
        end
      end
    end
    start_state
  end
end

class StorehouseWaybillEntry
  attr_reader :product, :amount
  def initialize(product, amount)
    @product = product
    @amount = amount
  end
end

class StorehouseWaybill
  attr_reader :waybill, :resources
  def initialize(waybill)
    @waybill = waybill
    @resources = Array.new
  end

  def add_resource product, amount
    @resources << StorehouseWaybillEntry.new(product, amount)
  end
end

class Storehouse < Array
  attr_reader :entity, :place
  def initialize(entity = nil, place = nil, real_amount = true, without_fill = false)
    @entity = entity
    @place = place
    @waybills = nil

    unless without_fill
      wbs = Waybill.not_disabled.find_by_owner_and_place @entity, @place,
            :include => { :deal => { :rules => :to }}
      releases = StorehouseRelease.find_all_by_owner_and_place_and_state @entity, @place,
            StorehouseRelease::INWORK, :include => {:deal => {:rules => :from}}
      if !wbs.nil?
        inner = Hash.new
        wbs.each do |item|
          if !item.deal.nil?
            item.deal.rules.each do |rule|
              if !inner.has_key?(rule.to.id)
                amount = StorehouseEntry.state(rule.to, releases)
                if (real_amount and !rule.to.state.nil? and rule.to.state.amount > 0) or
                    (!real_amount and amount > 0)
                  self << StorehouseEntry.new(rule.to, item.place, amount)
                end
                inner[rule.to.id] = true
              end
            end
          end
        end
      end
      self.group_by_real_resource
    end
  end

  def Storehouse.shipment
    a = Asset.find_by_tag("Storehouse Shipment")
    if a.nil?
      a = Asset.new :tag => "Storehouse Shipment"
      return nil unless a.save
    end
    a
  end

  def Storehouse.taskmaster entity, place
    resources = Hash.new
    sr = StorehouseRelease.find_all_by_to_id_and_place_id_and_state entity.id,
      place.id, StorehouseRelease::APPLIED
    sr.each do |release|
      release.deal.rules.each do |rule|
        if !resources.key?(rule.to.id)
          resources[rule.to.id] = rule.to.state.amount
        end
      end unless release.deal.nil? or release.deal.rules.nil?
    end unless sr.nil?
    s = Storehouse.new entity, place, true, true
    resources.each do |key, value|
      s << StorehouseEntry.new(Deal.find(key), s.place, value)
    end
    s
  end

  def Storehouse.taskmasters entity, place
    resources = Hash.new
    sr = StorehouseRelease.find_all_by_owner_and_place_and_state entity,
      place, StorehouseRelease::APPLIED
    sr.each do |release|
      release.deal.rules.each do |rule|
        if !resources.key?(rule.to.id)
          resources[rule.to.id] = rule.to.state.amount
        end
      end unless release.deal.nil? or release.deal.rules.nil?
    end unless sr.nil?
    s = Storehouse.new entity, place, true, true
    resources.each do |key, value|
      s << StorehouseEntry.new(Deal.find(key), s.place, value)
    end
    s
  end

  def waybills
    return @waybills if !@waybills.nil?
    waybills = Hash.new
    self.each do |sh_entry|
      amount = sh_entry.amount
      Waybill.not_disabled.order("created DESC").find_by_owner_and_place(@entity, @place).each do |waybill|
        waybill.resources.each do |resource|
          if sh_entry.product.id == resource.product.id or
              (!sh_entry.product.resource.real.nil? and !resource.product.resource.real.nil? and
                sh_entry.product.resource.real.id == resource.product.resource.real.id)
            unless waybills.key?(waybill.id)
              waybills[waybill.id] = StorehouseWaybill.new(waybill)
            end
            if amount <= resource.amount
              waybills[waybill.id].add_resource resource.product, amount
              amount = 0
            else
              waybills[waybill.id].add_resource resource.product, resource.amount
              amount -= resource.amount
            end
            break
          end
        end
        break if amount == 0
      end
    end
    @waybills = waybills.values
  end

  def waybill_by_id id
    self.waybills.each do |item|
      if item.waybill.id == id
        return item
      end
    end
    nil
  end

  def group_by_real_resource
    group = Hash.new
    origins = Array.new
    self.each do |item|
      unless item.product.resource.real.nil?
        rid = item.product.resource.real.id
        if group.has_key?(rid)
          if group[rid].has_key?(item.owner.id)
            group[rid][item.owner.id].add_amount item.amount
            group[rid][item.owner.id].add_real_amount item.real_amount
          else
            group[rid][item.owner.id] = item
          end
        else
          group[rid] = Hash.new
          group[rid][item.owner.id] = item
        end
      else
        origins << item
      end
    end
    self.clear
    origins.each do |item|
      self << item
    end
    group.each_value do |hash|
      hash.each_value do |value|
        self << value
      end
    end
  end
end
