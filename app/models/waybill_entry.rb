require 'resource'

class WaybillEntry < ActiveRecord::Base
  validates :resource, :waybill, :unit, :amount, :presence => true
  belongs_to :resource, :class_name => 'Asset'
  belongs_to :waybill

  def assign_resource_text(resource)
    return false unless self.resource.nil?
    if Asset.where(:tag => resource).length > 0
      self.resource = Asset.where(:tag => resource).first
    else
      self.resource = Asset.new(:tag => resource)
    end
  end
end
