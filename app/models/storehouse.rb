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
      @amount = deal.state.amount
    end
  end
end

class StoreHouse < Array
  attr_reader :entity
  def initialize(entity)
    @entity = nil
    if !entity.nil? and entity.instance_of?(Entity)
      @entity = entity
      Deal.where("entity_id = ? AND give_type = ? AND give_id = take_id AND give_type = take_type", entity.id, Asset)
          .each { |item| if !item.state.nil?; self << StoreHouseEntry.new(item); end; }
    end
  end
end
