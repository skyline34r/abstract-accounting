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

  private
  def check_before_save
    return false if self.waybill.nil?
    true
  end
end
