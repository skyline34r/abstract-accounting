class Asset < ActiveRecord::Base
  has_paper_trail

  validates_presence_of :tag
  validates_uniqueness_of :tag
  has_many :deal_gives, :class_name => "Deal", :as => :give
  has_many :deal_takes, :class_name => "Deal", :as => :take
  belongs_to :real, :class_name => "AssetReal"

  def real_tag
    if self.real.nil?
      self.tag
    else
      self.real.tag
    end
  end
end

class Money < ActiveRecord::Base
  has_paper_trail

  validates_presence_of :num_code
  validates_presence_of :alpha_code
  validates_uniqueness_of :num_code
  validates_uniqueness_of :alpha_code
  has_many :deal_gives, :class_name => "Deal", :as => :give
  has_many :deal_takes, :class_name => "Deal", :as => :take
  has_many :quotes

  def real_tag
    self.alpha_code
  end

  def quote
    quotes.where(:day =>
        quotes.maximum("day")
      ).first
  end
end
