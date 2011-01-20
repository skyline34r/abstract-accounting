require "state_action"

class State < ActiveRecord::Base
  validates :amount, :start, :side, :deal, :presence => true
  validates_inclusion_of :side, :in => ["passive", "active"] #[1, 0]
  belongs_to :deal
  
  after_initialize :do_init

  include StateAction
end
