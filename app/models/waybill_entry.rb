require 'resource'

class WaybillEntry < ActiveRecord::Base
  validates :resource, :waybill, :unit, :amount, :presence => true
  belongs_to :resource, :class_name => 'Asset'
  belongs_to :waybill
end
