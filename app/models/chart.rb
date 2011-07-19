class Chart < ActiveRecord::Base
  has_paper_trail

  belongs_to :currency, :class_name => 'Money'
  validates :currency, :presence => true
  validates_uniqueness_of :currency_id
end
