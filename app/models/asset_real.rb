class AssetReal < ActiveRecord::Base
  validates :tag, :presence => true, :uniqueness => true
  has_many :assets, :foreign_key => 'real_id'
end
