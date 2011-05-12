require "resource"

class StorehouseEntry
  attr_reader :owner, :place, :product, :amount
  def initialize(deal, place)
    @amount = 0
    @product = nil
    @owner = nil
    @place = place
    if !deal.nil?
      @owner = deal.entity
      @product = Product.find_by_resource_id deal.give
      @amount = StorehouseEntry.state(deal)
    end
  end

  def StorehouseEntry.state(deal)
    return 0 if deal.nil? or deal.state.nil?
    start_state = deal.state.amount
    releases = StorehouseRelease.find_all_by_state StorehouseRelease::INWORK
    releases.each do |item|
      if !item.deal.nil?
        item.deal.rules.each do |rule|
          if rule.from == deal
            start_state -= rule.rate
          end
        end
      end
    end
    start_state
  end
end

class Storehouse < Array
  attr_reader :entity, :place
  def initialize(entity = nil, place = nil)
    @entity = entity
    @place = place
    wbs = Waybill.find_by_owner_and_place @entity, @place
    if !wbs.nil?
      wbs.each do |item|
        if !item.deal.nil?
          item.deal.rules.each do |rule|
            if StorehouseEntry.state(rule.to) > 0
              self << StorehouseEntry.new(rule.to, item.place)
            end
          end
        end
      end
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
end
