class Journal < ActiveRecord::Base
  validates :created_at, :presence => true
  validates :created_by_id, :presence => true
  validates :fact_id, :presence => true, :uniqueness => true
  
  belongs_to :created_by, :class_name => "Entity"
  belongs_to :fact
end
