require "resource"

class Product < ActiveRecord::Base
  has_paper_trail

  validates :unit, :presence => true
  validates :resource_id, :uniqueness => true, :presence => true
  belongs_to :resource, :class_name => 'Asset', :autosave => true

  def resource=(asset)
    if !asset.nil?
      if asset.instance_of?(Asset)
        self[:resource] = asset
        if asset.new_record?
          self.resource_id = -1
        else
          self.resource_id = asset.id
        end
      else
        a = asset.to_s
        if !Product.find_asset_by_tag(a).nil?
          self[:resource] = Product.find_asset_by_tag(a)
          self.resource_id = self[:resource].id
        else
          self[:resource] = Asset.new(:tag => a)
          self.resource_id = -1
        end
      end
    end
  end

  def resource
    if self[:resource].nil? and !self.resource_id.nil? and self.resource_id > -1
      self[:resource] = Asset.find(self.resource_id)
    end
    self[:resource]
  end

  def Product.find_by_resource_tag name
    asset = Product.find_asset_by_tag name
    if !asset.nil?
      return Product.find_by_resource_id asset.id
    end
    nil
  end

  def Product.find_asset_by_tag tag
    Asset.find(:first, :conditions => ["lower(tag) = lower(?)", tag])
  end

  before_save :product_before_save

  private
  def product_before_save
    if self.resource_id == -1
      return false unless self.resource.save
      self.resource_id = self.resource.id
    end
    true
  end
end
