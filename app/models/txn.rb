class Txn < ActiveRecord::Base
  validates :value, :fact, :status, :presence => true
  validates_uniqueness_of :fact
  belongs_to :fact
end
