class Place < ActiveRecord::Base
  validates :tag, :uniqueness => true, :presence => true
end
