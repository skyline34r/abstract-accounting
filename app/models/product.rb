require "resource"

class Product < ActiveRecord::Base
  validates :unit, :asset_id, :presence => true
  validates :asset_id, :uniqueness => true
  belongs_to :asset, :class_name => "Asset"
end
