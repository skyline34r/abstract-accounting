require "state_action"

class Balance < ActiveRecord::Base
  validates :amount, :value, :start, :side, :deal, :presence => true
  validates_inclusion_of :side, :in => ["passive", "active"] #[1, 0]
  validates_uniqueness_of :start, :scope => :deal_id
  belongs_to :deal
  
  after_initialize :do_init

  include StateAction
end
