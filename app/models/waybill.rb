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

class Waybill < ActiveRecord::Base
  #validations
  validates :document_id, :presence => true
  validates :owner_id, :presence => true
  validates :place_id, :presence => true
  validates :from_id, :presence => true
  validates :created, :presence => true
  
  validates_with VatinValidator, :if => "!vatin.nil? && !vatin.empty?"
  validates :vatin, :uniqueness => true, :if => "!vatin.nil? && !vatin.empty?"

  validates_with ResourcesValidator
  #associations
  belongs_to :owner, :class_name => 'Entity'
  belongs_to :place
  belongs_to :from, :class_name => 'Entity'
  belongs_to :deal

  def from=(entity)
    if !entity.nil?
      if entity.instance_of?(Entity)
        self[:from] = entity
        if entity.new_record?
          self.from_id = -1
        else
          self.from_id = entity.id
        end
      else
        a = entity.to_s
        if !Entity.find(:first, :conditions => ["lower(tag) = lower(?)", a]).nil?
          self[:from] = Entity.find(:first, :conditions => ["lower(tag) = lower(?)", a])
          self.from_id = self[:from].id
        else
          self[:from] = Entity.new(:tag => a)
          self.from_id = -1
        end
      end
    end
  end

  def from
    if self[:from].nil? and !self.from_id.nil? and self.from_id > -1
      self[:from] = Entity.find(self.from_id)
    end
    self[:from]
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

  after_initialize :waybill_initialize
  before_save :waybill_before_save

  def Waybill.find_by_owner_and_place entity = nil, place = nil, *args
    if entity.nil? or (!entity.nil? and place.nil?)
      Waybill.all *args
    else
      Waybill.find_all_by_place_id_and_owner_id(place, entity, *args)
    end
  end

  def has_in_the_storehouse?
    sh = Storehouse.new self.owner, self.place
    return true if !sh.waybill_by_id(self.id).nil?
    false
  end

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
      return false if !Fact.new(:amount => 1.0,
              :day => self.created,
              :from => nil,
              :to => self.deal,
              :resource => self.deal.give).save
    else
      return false
    end
    true
  end
end
