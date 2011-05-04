require 'resource'

class WaybillEntry < ActiveRecord::Base
  validates :resource, :unit, :amount, :presence => true
  belongs_to :resource, :class_name => 'Asset'
  belongs_to :waybill

  def assign_resource_text(resource)
    return false unless self.resource.nil?
    if !Asset.find(:first, :conditions => ["lower(tag) = lower(?)", resource]).nil?
      self.resource = Asset.find(:first, :conditions => ["lower(tag) = lower(?)", resource])
    else
      self.resource = Asset.new(:tag => resource)
    end
  end

  before_save :check_before_save #check bill is exist, do not save without bill

  def storehouse_deal(entity)
    return nil if self.resource.id.nil? or entity.nil? or entity.id.nil?
    storehouses = Deal.find_all_by_give_and_take_and_entity(self.resource, self.resource, entity)
    if storehouses.length == 1
      storehouses.first
    else
      Deal.new :entity => entity, :give => self.resource, :take => self.resource,
        :rate => 1.0, :tag => "storehouse entity: " + entity.tag + "; resource: " + self.resource.tag + ";"
    end
  end

  private
  def check_before_save
    return false if self.waybill.nil?
    true
  end
end
