class Rule < ActiveRecord::Base
  validates :deal, :from, :to, :rate,
    :presence => true
  validates_inclusion_of :fact_side, :in => [ true, false ]
  validates_inclusion_of :change_side, :in => [ true, false ]
  belongs_to :deal
  belongs_to :from, :class_name => "Deal"
  belongs_to :to, :class_name => "Deal"
end
