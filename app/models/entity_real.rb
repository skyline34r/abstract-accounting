class EntityReal < ActiveRecord::Base
  validates :tag, :presence => true, :uniqueness => true
end
