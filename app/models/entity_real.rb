class EntityReal < ActiveRecord::Base
  validates :tag, :presence => true, :uniqueness => true
  has_many :entities, :foreign_key => "real_id"
end
