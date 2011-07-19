class Role < ActiveRecord::Base
  has_paper_trail

	validates :name, :presence => true, :uniqueness => true
  has_and_belongs_to_many :users
end
