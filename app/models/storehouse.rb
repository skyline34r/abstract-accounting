require "resource"

class StoreHouseEntry
  attr_reader :deal, :amount, :resource
  def initialize(deal)
    @deal = nil
    @amount = 0
    @resource = nil
    if !deal.nil? and deal.instance_of?(Deal)
      @deal = deal
      @resource = deal.give
      @amount = StoreHouseEntry.state(deal)
    end
  end

  def StoreHouseEntry.state(deal)
    return 0 if deal.nil? or deal.state.nil?
    start_state = deal.state.amount
    releases = StorehouseRelease.find_all_by_state StorehouseRelease::INWORK
    releases.each do |item|
      item.deal.rules.each do |rule|
        if rule.from == deal
          start_state -= rule.rate
        end
      end
    end
    start_state
  end
end

class StoreHouse < Array
  attr_reader :entity
  def initialize(entity)
    @entity = nil
    if !entity.nil? and entity.instance_of?(Entity)
      @entity = entity
      Deal.where("entity_id = ? AND give_type = ? AND give_id = take_id AND give_type = take_type", entity.id, Asset)
          .each { |item| if StoreHouseEntry.state(item) > 0; self << StoreHouseEntry.new(item); end; }
    end
  end
end
