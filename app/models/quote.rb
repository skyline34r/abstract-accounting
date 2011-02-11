class Quote < ActiveRecord::Base
  validates :money, :day, :rate, :diff, :presence => true
  validates_uniqueness_of :money_id, :scope => :day
  belongs_to :money

  after_initialize :do_initialize

  private
  def do_initialize
    self.diff ||= 0.0 if new_record?
  end
end
