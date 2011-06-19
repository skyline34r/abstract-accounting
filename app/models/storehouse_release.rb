require "waybill"

class StorehouseReleaseEntry < WaybillEntry
  def state(entity, place, date)
    storage_deal = self.storehouse_deal entity
    return 0 if storage_deal.nil? or storage_deal.state(date).nil?
    start_state = storage_deal.state(date).amount
    releases = StorehouseRelease.find_all_by_owner_and_place_and_state entity, place,
        StorehouseRelease::INWORK
    releases.each do |item|
      item.deal.rules.each do |rule|
        if rule.from.id == storage_deal.id
          start_state -= rule.rate
        end
      end
    end
    start_state
  end
end

class StorehouseReleaseValidator < ActiveModel::Validator
  def validate(record)
    if record.state == StorehouseRelease::UNKNOWN
      record.errors[:resources] = "must be not empty" if record.resources.empty?
      record.resources.each do |item|
        d = item.storehouse_deal record.owner
        record.errors[:resources] = "invalid resource" if d.nil?
        record.errors[:resources] = "invalid amount" if !d.nil? and
            (item.amount > item.state(record.owner, record.place, record.created) or
                item.amount <= 0)
      end
    else
      record.errors[:release] = "cann't change release after save" \
        if record.changed? and (record.changed.length != 1 or
           !record.state_changed?)
    end
  end
end

class StorehouseRelease < ActiveRecord::Base
  #States
  INWORK = 1
  CANCELED = 2
  APPLIED = 3
  UNKNOWN = 0
  #validations
  validates :owner_id, :presence => true
  validates :place_id, :presence => true
  validates :to_id, :presence => true
  validates :created, :presence => true
  validates :state, :presence => true

  validates_with StorehouseReleaseValidator
  #associations
  belongs_to :owner, :class_name => 'Entity'
  belongs_to :place
  belongs_to :to, :class_name => 'Entity'
  belongs_to :deal

  def to=(entity)
    if !entity.nil?
      if entity.instance_of?(Entity)
        self[:to] = entity
        if entity.new_record?
          self.to_id = -1
        else
          self.to_id = entity.id
        end
      else
        a = entity.to_s
        if !Entity.find_by_tag_case_insensitive(a).nil?
          self[:to] = Entity.find_by_tag_case_insensitive(a)
          self.to_id = self[:to].id
        else
          self[:to] = Entity.new(:tag => a)
          self.to_id = -1
        end
      end
    end
  end

  def to
    if self[:to].nil? and !self.to_id.nil? and self.to_id > -1
      self[:to] = Entity.find(self.to_id)
    end
    self[:to]
  end

  def add_resource product, amount
    @entries << StorehouseReleaseEntry.new(product, amount)
  end

  def resources
    if @entries.empty? and !self.deal.nil?
      self.deal.rules.each do |item|
        @entries << StorehouseReleaseEntry.new(Product.find_by_resource_id(item.from.take), item.rate)
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
    if self.state == INWORK and !self.deal.nil?
      return false unless Fact.new(:amount => 1.0,
            :day => self.created,
            :from => nil,
            #if using self.deal - instance_of?("Deal") return false
            :to => Deal.find(self.deal.id),
            :resource => self.deal.give).save
      self.state = APPLIED
      return self.save
    end
    false
  end

  def StorehouseRelease.find_all_by_owner_and_place_and_state entity = nil,
      place = nil, state = nil, *args
    if entity.nil? or (!entity.nil? and place.nil?)
      if state.nil?
        StorehouseRelease.all *args
      else
        StorehouseRelease.find_all_by_state state, *args
      end
    else
      if state.nil?
        StorehouseRelease.find_all_by_owner_id_and_place_id entity, place, *args
      else
        StorehouseRelease.find_all_by_state_and_owner_id_and_place_id state, entity, place, *args
      end
    end
  end

  after_initialize :sr_initialize
  before_save :sr_before_save

  private
  def sr_initialize
    self.state = UNKNOWN if self.id.nil?
    @entries = Array.new
  end

  def sr_before_save
    if self.new_record?
      if self.to_id == -1
        return false unless self.to.save
        self.to_id = self.to.id
      end
      shipment = Storehouse.shipment
      self.deal = Deal.new :tag => "Storehouse release shipment #" +
          (StorehouseRelease.last.nil? ? 0 : StorehouseRelease.last.id).to_s,
        :rate => 1.0, :entity => self.owner, :give => shipment,
        :take => shipment, :isOffBalance => true
      return false unless self.deal.save
      @entries.each_with_index do |item, idx|
        if item.product.new_record?
          return false unless item.product.save
        end
        ownerItem = item.storehouse_deal self.owner
        return false if ownerItem.nil? or !ownerItem.save
        toItem = item.storehouse_deal self.to
        return false if toItem.nil? or !toItem.save

        return false if self.deal.rules.create(:tag => self.deal.tag + "; rule" + idx.to_s,
          :from => ownerItem, :to => toItem, :fact_side => false,
          :change_side => true, :rate => item.amount).nil?
      end
      self.deal_id = self.deal.id
      self.state = INWORK if self.state == UNKNOWN
    end
    true
  end
end
