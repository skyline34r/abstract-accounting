class Task < ActiveRecord::Base

  #states
  Unconfirmed = 1
  Unassigned = 2
  InWork = 3
  Implemented = 4
  Closed = 5
  #states

  validates :summary, :status, :reporter, :assignee, :presence => true
  validates :summary, :uniqueness => true
  validates :status, :inclusion => { :in => [Unconfirmed, Unassigned, InWork, Implemented, Closed] }
  belongs_to :reporter, :class_name => 'User'
  belongs_to :assignee, :class_name => 'User'
end
