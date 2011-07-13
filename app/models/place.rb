class Place < ActiveRecord::Base
  has_paper_trail

  validates :tag, :uniqueness => true, :presence => true
end
