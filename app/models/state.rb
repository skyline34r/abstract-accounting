require "state_action"
require "closable"

class State < ActiveRecord::Base
  has_paper_trail

  validates :amount, :start, :side, :deal, :presence => true
  validates_inclusion_of :side, :in => ["passive", "active"] #[1, 0]
  validates_uniqueness_of :start, :scope => :deal_id
  belongs_to :deal
  
  after_initialize :do_init
  scope :open, where("states.paid IS NULL")

  def self.find_all_between_start_and_stop(start, stop)
    State.where("start <= ? AND (paid > ? OR paid IS NULL)",
      DateTime.new(stop.year, stop.month, stop.day) + 1,
      DateTime.new(start.year, start.month, start.day) + 1)
  end

  include Closable
  include StateAction
end
