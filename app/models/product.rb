require "resource"

class Product < ActiveRecord::Base
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
        if !Asset.find(:first, :conditions => ["lower(tag) = lower(?)", a]).nil?
          self[:resource] = Asset.find(:first, :conditions => ["lower(tag) = lower(?)", a])
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
