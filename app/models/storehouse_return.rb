require "waybill"

class StorehouseReturnEntry < WaybillEntry
  def state(entity, date)
    storage_deal = self.storehouse_deal entity
    return 0 if storage_deal.nil? or storage_deal.state(date).nil?
    storage_deal.state(date).amount
  end
end

class StorehouseReturnValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:resources] = "must be not empty" if record.resources.empty?
    record.resources.each do |item|
      d = item.storehouse_deal record.from
      record.errors[:resources] = "invalid resource" if d.nil?
      record.errors[:resources] = "invalid amount" if !d.nil? and
          (item.amount > item.state(record.from, record.created_at) or
              item.amount <= 0)
    end
  end
end

class StorehouseReturn < ActiveRecord::Base
  validates :from_id, :presence => true
  validates :place_id, :presence => true
  validates :to_id, :presence => true
  validates :created_at, :presence => true

  validates_with StorehouseReturnValidator
  #associations
  belongs_to :from, :class_name => 'Entity'
  belongs_to :to, :class_name => 'Entity'
  belongs_to :place
  belongs_to :deal

  def add_resource product, amount
    @entries << StorehouseReturnEntry.new(product, amount)
  end

  def resources
    if @entries.empty? and !self.deal.nil?
      self.deal.rules.each do |item|
        @entries << StorehouseReturnEntry.new(Product.find_by_resource_id(item.from.take), item.rate)
      end
    end
    @entries
  end

  after_initialize :sr_initialize
  before_save :sr_before_save

  private
  def sr_initialize
    @entries = Array.new
  end

  def sr_before_save
    if self.new_record?
      shipment = Storehouse.shipment
      self.deal = Deal.new :tag => "Storehouse return shipment #" +
          (StorehouseReturn.last.nil? ? 0 : StorehouseReturn.last.id).to_s,
        :rate => 1.0, :entity => self.from, :give => shipment,
        :take => shipment, :isOffBalance => true
      return false unless self.deal.save
      @entries.each_with_index do |item, idx|
        from_item = item.storehouse_deal self.from
        return false if from_item.nil? or !from_item.save
        to_item = item.storehouse_deal self.to
        return false if to_item.nil? or !to_item.save

        return false if self.deal.rules.create(:tag => self.deal.tag + "; rule" + idx.to_s,
          :from => from_item, :to => to_item, :fact_side => false,
          :change_side => true, :rate => item.amount).nil?
      end
      self.deal_id = self.deal.id
      return false if !Fact.new(:amount => 1.0,
              :day => self.created_at,
              :from => nil,
              :to => self.deal,
              :resource => self.deal.give).save
    else
      return false
    end
    true
  end
end
