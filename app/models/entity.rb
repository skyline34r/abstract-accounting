class Entity < ActiveRecord::Base
  has_paper_trail

	validates_presence_of :tag
	validates_uniqueness_of :tag
	has_many :deals

  def self.find_by_tag_case_insensitive tag
    Entity.find(:first, :conditions => ["lower(tag) = lower(?)", tag])
  end
end
