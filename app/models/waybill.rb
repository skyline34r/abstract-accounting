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
  has_paper_trail

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
  belongs_to :disable_deal, :class_name => 'Deal'

  scope :not_disabled, where("disable_deal_id IS NULL")
  scope :disabled, where("disable_deal_id IS NOT NULL")
  scope :by_storekeeper, lambda { |owner = nil, place = nil|
    if !owner.nil? and !place.nil?
      where("owner_id = ? AND place_id = ?", owner.id, place.id)
    end
  }

  alias_method :original_from=, :from=
  alias_method :original_from, :from
  def from=(entity)
    if !entity.nil?
      if entity.instance_of?(Entity)
        self.original_from = entity
        if entity.new_record?
          self.from_id = -1
        else
          self.from_id = entity.id
        end
      else
        a = entity.to_s
        if !Entity.find_by_tag_case_insensitive(a).nil?
          self.original_from = Entity.find_by_tag_case_insensitive(a)
          self.from_id = self.original_from.id
        else
          self.original_from = Entity.new(:tag => a)
          self.from_id = -1
        end
      end
    end
  end

  def from
    if self.original_from.nil? and !self.from_id.nil? and self.from_id > -1
      self.original_from = Entity.find(self.from_id)
    end
    self.original_from
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

  def warehouse_resources
    resources = Array.new
    ActiveRecord::Base.connection.execute("
    SELECT products.id as product_id, SUM(rules.rule_rate) as waybills_rate, SUM(rules.amount) as warehouse_amount FROM (
      SELECT rules.to_id as rule_to_id, SUM(rules.rate) as rule_rate, states.amount as amount FROM rules
        INNER JOIN waybills ON waybills.deal_id = rules.deal_id
        INNER JOIN states ON states.deal_id = rules.to_id AND states.paid IS NULL
      WHERE waybills.created >= (
              SELECT waybills.created FROM waybills WHERE waybills.id = " + self.id.to_s + "
            ) AND rules.to_id IN (
              SELECT rules.to_id FROM rules
                INNER JOIN waybills ON waybills.deal_id = rules.deal_id
              WHERE waybills.id = " + self.id.to_s + "
            )
      GROUP BY rules.to_id
      UNION
      SELECT rules.to_id as rule_to_id, -rules.rate as rule_rate, 0.0 as amount FROM rules
        INNER JOIN waybills ON waybills.deal_id = rules.deal_id
      WHERE waybills.id = " + self.id.to_s + "
      UNION
      SELECT rules.from_id as rule_to_id, 0.0 as rule_rate, -SUM(rules.rate) as amount FROM rules
        INNER JOIN storehouse_releases ON storehouse_releases.deal_id = rules.deal_id
      WHERE storehouse_releases.created >= (
              SELECT waybills.created FROM waybills WHERE waybills.id = " + self.id.to_s + "
            ) AND rules.from_id IN (
              SELECT rules.to_id FROM rules
                INNER JOIN waybills ON waybills.deal_id = rules.deal_id
              WHERE waybills.id = " + self.id.to_s + "
            ) AND storehouse_releases.state = 1
      GROUP BY rules.from_id
    ) as rules
      INNER JOIN deals ON deals.id = rules.rule_to_id
      INNER JOIN assets ON assets.id = deals.give_id
      INNER JOIN products ON products.resource_id = assets.id
    GROUP BY rules.rule_to_id;
    ").each do |item|
      resources <<
          WaybillEntry.new(Product.find(item["product_id"]), item["warehouse_amount"] - item["waybills_rate"]) if
            item["warehouse_amount"] != 0 && item["warehouse_amount"] > item["waybills_rate"]
    end
    resources
  end

  def disable arg_comment
    self.errors[:comment] << "mustn't be empty'" if arg_comment.nil? or arg_comment.empty?
    self.errors[:disable] << "Record already disabled" unless self.disable_deal.nil?
    return false unless self.errors.empty?
    self.comment = arg_comment
    self.save
  end

  after_initialize :waybill_initialize
  before_save :waybill_before_save

  def has_in_the_storehouse?
    has = false
    ActiveRecord::Base.connection.execute("
    SELECT CASE WHEN SUM(rules.amount) = 0 THEN 0 WHEN SUM(rules.rule_rate) < SUM(rules.amount) THEN 1 ELSE 0 END as has FROM (
      SELECT rules.to_id as rule_to_id, SUM(rules.rate) as rule_rate, states.amount as amount FROM rules
        INNER JOIN waybills ON waybills.deal_id = rules.deal_id
        INNER JOIN states ON states.deal_id = rules.to_id AND states.paid IS NULL
      WHERE waybills.created >= (
              SELECT waybills.created FROM waybills WHERE waybills.id = " + self.id.to_s + "
            ) AND rules.to_id IN (
              SELECT rules.to_id FROM rules
                INNER JOIN waybills ON waybills.deal_id = rules.deal_id
              WHERE waybills.id = " + self.id.to_s + "
            )
      GROUP BY rules.to_id
      UNION
      SELECT rules.to_id as rule_to_id, -rules.rate as rule_rate, 0.0 as amount FROM rules
        INNER JOIN waybills ON waybills.deal_id = rules.deal_id
      WHERE waybills.id = " + self.id.to_s + "
      UNION
      SELECT rules.from_id as rule_to_id, 0.0 as rule_rate, -SUM(rules.rate) as amount FROM rules
        INNER JOIN storehouse_releases ON storehouse_releases.deal_id = rules.deal_id
      WHERE storehouse_releases.created >= (
              SELECT waybills.created FROM waybills WHERE waybills.id = " + self.id.to_s + "
            ) AND rules.from_id IN (
              SELECT rules.to_id FROM rules
                INNER JOIN waybills ON waybills.deal_id = rules.deal_id
              WHERE waybills.id = " + self.id.to_s + "
            ) AND storehouse_releases.state = 1
      GROUP BY rules.from_id
    ) as rules
    GROUP BY rules.rule_to_id;
    ").each do |item|
      has = item["has"] == 1 ? true : has
    end
    has
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
      dt_now = DateTime.now
      return false if !Fact.new(:amount => 1.0,
              :day => DateTime.civil(dt_now.year, dt_now.month, dt_now.day, 12, 0, 0),
              :from => nil,
              :to => self.deal,
              :resource => self.deal.give).save
    elsif self.comment_changed?
      shipment = Storehouse.shipment
      deal = Deal.new :tag => "Waybill disabled shipment #" + self.id.to_s,
          :rate => 1.0, :entity_id => self.owner_id, :give => shipment,
          :take => shipment, :isOffBalance => true
      return false unless deal.save
      idx = 0
      self.deal.rules.each do |rule|
        return false unless deal.rules.create(:tag => deal.tag + "; rule" + idx.to_s,
          :from_id => rule.to_id, :to_id => rule.from_id, :fact_side => false,
          :change_side => true, :rate => rule.rate)
        idx += 1
      end
      dt_now = DateTime.now
      self.disable_deal = deal
      return false unless Fact.new(:amount => 1.0,
              :day => DateTime.civil(dt_now.year, dt_now.month, dt_now.day, 12, 0, 0),
              :from => nil,
              :to => self.disable_deal,
              :resource => self.disable_deal.give).save
    else
      return false
    end
    true
  end
end
