
class StorehouseRelease < ActiveRecord::Base
  attr_accessor :owner, :to
  validates :created, :presence => true
  validates :owner, :to, :presence => true, :if => "self.state == UNKNOWN"
  belongs_to :deal

  #States
  INWORK = 1
  CANCELED = 2
  APPLIED = 3
  UNKNOWN = 0

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
  end

  def sv_before_save
    self.state = INWORK if self.state == UNKNOWN
    true
  end
end
