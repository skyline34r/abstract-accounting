require "resource"

class StorehouseEntry
  attr_reader :deal, :owner, :place, :amount, :resource
  def initialize(deal)
    @deal = nil
    @amount = 0
    @resource = nil
    @owner = nil
    @place = nil
    if !deal.nil? and deal.instance_of?(Deal)
      @deal = deal
      @owner = deal.entity
      user = User.find_by_entity_id(deal.entity.id)
      if !user.nil?
        @place = user.place
      end
      @resource = deal.give
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
  attr_reader :entity
  def initialize(entity)
    @entity = nil
    if !entity.nil? and entity.instance_of?(Entity)
      @entity = entity
      Deal.where("entity_id = ? AND give_type = ? AND give_id = take_id AND give_type = take_type", entity.id, Asset)
          .each { |item| if StorehouseEntry.state(item) > 0; self << StorehouseEntry.new(item); end; }
    end
  end
end
