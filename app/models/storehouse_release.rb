require "resource"

class StorehouseReleaseEntry
  attr_reader :resource, :amount
  def initialize(resource, amount)
    @resource = resource
    @amount = amount
  end
end

class StorehouseReleaseValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:resources] = "must be not empty" if record.resources.empty?
  end
end

class StorehouseRelease < ActiveRecord::Base

  #States
  INWORK = 1
  CANCELED = 2
  APPLIED = 3
  UNKNOWN = 0

  attr_accessor :owner, :to
  validates :created, :owner, :to, :state, :presence => true
  validates_with StorehouseReleaseValidator
  belongs_to :deal

  after_initialize :sv_after_initialize
  before_save :sv_before_save

  def to=(entity)
    if !entity.nil?
      if entity.instance_of?(Entity)
        @to = entity
      else
        e = entity.to_s
        if !Entity.find(:first, :conditions => ["lower(tag) = lower(?)", e]).nil?
          @to = Entity.find(:first, :conditions => ["lower(tag) = lower(?)", e])
        else
          @to = Entity.new(:tag => e)
        end
      end
    end
  end

  def add_resource(resource, amount)
    @entries << StorehouseReleaseEntry.new(resource, amount)
  end

  def resources
    @entries
  end

  def cancel
    if self.state == INWORK
      self.state = CANCELED
      return self.save
    end
    false
  end

  def apply
    if self.state == INWORK
      self.state = APPLIED
      return self.save
    end
    false
  end

  private
  def sv_after_initialize
    self.state = UNKNOWN if self.id.nil?
    @entries = Array.new
  end

  def sv_before_save
    self.state = INWORK if self.state == UNKNOWN
    true
  end
end
