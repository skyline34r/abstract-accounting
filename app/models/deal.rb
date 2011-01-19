class Deal < ActiveRecord::Base
  validates :tag, :rate, :presence => true
  belongs_to :entity
  belongs_to :give, :polymorphic => true
  belongs_to :take, :polymorphic => true
  has_many :states

  def state(day)
    states.where(:start =>
        if !day.nil?
          states.where("start <= ?", day)
            .maximum("start")
        else
          states.maximum("start")
        end
      ).first
  end
end
