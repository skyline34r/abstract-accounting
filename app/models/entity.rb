class Entity < ActiveRecord::Base
	validates_presence_of :tag
	validates_uniqueness_of :tag
	has_many :deals

  belongs_to :real, :class_name => "EntityReal"

  def self.find_by_tag_case_insensitive tag
    Entity.find(:first, :conditions => ["lower(tag) = lower(?)", tag])
  end
end
