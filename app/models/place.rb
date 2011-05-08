class Place < ActiveRecord::Base
  validates :tag, :uniqueness => true
end
