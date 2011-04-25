class Task < ActiveRecord::Base
  validates :summary, :status, :reporter, :assignee, :presence => true
  validates :summary, :uniqueness => true
  belongs_to :reporter, :class_name => 'User'
  belongs_to :assignee, :class_name => 'User'
end
