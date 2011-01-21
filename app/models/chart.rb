class Chart < ActiveRecord::Base
  belongs_to :currency, :class_name => 'Money'
  validates :currency, :presence => true
  validates_uniqueness_of :money_id
end
