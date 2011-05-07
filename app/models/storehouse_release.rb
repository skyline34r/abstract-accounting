require "resource"

class StorehouseReleaseEntry
  attr_reader :resource, :amount
  def initialize(resource, amount)
    @resource = resource
    @amount = amount
  end

  def deal(entity)
    Deal.find_by_entity_id_and_take_id_and_give_id_and_take_type_and_give_type(entity, @resource, @resource, Asset, Asset)
  end

  def storehouse_deal(entity)
    return nil if entity.nil?
    storehouses =
      if self.resource.id.nil? or entity.id.nil?
        Array.new
      else
        Deal.find_all_by_give_and_take_and_entity(self.resource, self.resource, entity)
      end
    if storehouses.length == 1
      storehouses.first
    else
      Deal.new :entity => entity, :give => self.resource, :take => self.resource,
        :rate => 1.0, :isOffBalance => true,
        :tag => "storehouse entity: " + entity.tag + "; resource: " + self.resource.tag + ";"
    end
  end
end

class StorehouseReleaseValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:resources] = "must be not empty" if record.resources.empty?
    record.resources.each do |item|
      d = item.deal(record.owner)
      record.errors[:resources] = "invalid resource" if d.nil?
      #TODO: check other not applied releases for state
      record.errors[:resources] = "invalid amount" if !d.nil? and (d.state.nil? or item.amount > d.state.amount or item.amount <= 0)
    end
  end
end

class StorehouseRelease < ActiveRecord::Base

  #States
  INWORK = 1
  CANCELED = 2
  APPLIED = 3
  UNKNOWN = 0

  attr_accessor :owner, :to
  validates :created, :owner, :to, :state, :presence => true
  validates_with StorehouseReleaseValidator
  belongs_to :deal

  after_initialize :sv_after_initialize
  before_save :sv_before_save

  def to=(entity)
    if !entity.nil?
      if entity.instance_of?(Entity)
        @to = entity
      else
        e = entity.to_s
        if !Entity.find(:first, :conditions => ["lower(tag) = lower(?)", e]).nil?
          @to = Entity.find(:first, :conditions => ["lower(tag) = lower(?)", e])
        else
          @to = Entity.new(:tag => e)
        end
      end
    end
  end

  def add_resource(resource, amount)
    @entries << StorehouseReleaseEntry.new(resource, amount)
  end

  def resources
    if @entries.empty? and !self.deal.nil?
      self.deal.rules.each do |item|
        @entries << StorehouseReleaseEntry.new(item.from.take, item.rate)
      end
    end
    @entries
  end

  def cancel
    if self.state == INWORK
      self.state = CANCELED
      return self.save
    end
    false
  end

  def apply
    if self.state == INWORK
      self.state = APPLIED
      return self.save
    end
    false
  end

  private
  def sv_after_initialize
    self.state = UNKNOWN if self.id.nil?
    @entries = Array.new
  end

  def sv_before_save
    if self.deal.nil? or self.deal.id.nil?
      a = self.sr_asset
      self.deal = Deal.new :tag => "StorehouseRelease created: " + self.created.to_s + "; owner: " + @owner.tag,
        :rate => 1.0, :entity => @owner, :give => a,
        :take => a, :isOffBalance => true
      return false if !self.deal.save
      @entries.each_with_index do |item, idx|
        dItem = item.storehouse_deal self.to
        return false if dItem.nil? or !dItem.save
        #create rules
        self.deal.rules.create :tag => self.deal.tag + "; rule" + idx.to_s,
          :from => item.deal(self.owner), :to => dItem, :fact_side => false,
          :change_side => false, :rate => item.amount
      end
      self.deal_id = self.deal.id
    end
    self.state = INWORK if self.state == UNKNOWN
    true
  end

  protected
  def sr_asset
    a = Asset.find_by_tag("Storehouse Release")
    if a.nil?
      a = Asset.new :tag => "Storehouse Release"
    end
    a
  end
end

#TODO: apply
