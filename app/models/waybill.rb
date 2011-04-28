class Waybill < ActiveRecord::Base
  validates :date, :owner, :organization, :presence => true
  belongs_to :owner, :class_name => 'Entity'
  belongs_to :organization, :class_name => 'Entity'
end
