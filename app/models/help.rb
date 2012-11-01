class Help < ActiveRecord::Base
  attr_accessible :looked, :user_id
  has_many :users
end
