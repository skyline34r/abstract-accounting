

#validate vatin only for Russian Federation
class WaybillValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:vatin] <<
      "Vatin is invalid. Valid count of numbers is 10 or 12" if
      record.vatin.length != 10 and record.vatin.length != 12
    record.errors[:vatin] << "VATIN is not numeric" if
      record.vatin.match(/\A\d+\Z/) == nil
    record.errors[:vatin] << "Invalid checksum" if !vatin?(record.vatin)
  end

  def vatin?(vatin)
    base_prefix = [3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8]
    valid = false
    if vatin.length == 10
      valid = check_sum vatin, base_prefix[2..10], vatin[-1].to_i
    elsif vatin.length == 12
      check_sum(vatin, base_prefix[1..10], vatin[-2].to_i) do
        valid = check_sum vatin, base_prefix, vatin[-1].to_i
      end
    end
    valid
  end

  def check_sum(vatin, prefix, sum)
    res = 0
    prefix.each_index do |index|
      res += vatin[index].to_i * prefix[index]
    end
    if (res % 11) % 10 == sum
      if block_given?
        yield
      else
        true
      end
    else
      false
    end
  end
end

class Waybill < ActiveRecord::Base
  validates :date, :owner, :organization, :presence => true
  validates_with WaybillValidator, :if => "!vatin.nil? && !vatin.empty?"
  validates_uniqueness_of :vatin, :if => "!vatin.nil? && !vatin.empty?"
  belongs_to :owner, :class_name => 'Entity'
  belongs_to :organization, :class_name => 'Entity'
  has_many :waybill_entries
  #temp functionality
  def assign_organization_text(entity)
    return false unless self.organization.nil?
    if !Entity.find(:first, :conditions => ["lower(tag) = lower(?)", entity]).nil?
      self.organization = Entity.find(:first, :conditions => ["lower(tag) = lower(?)", entity])
    else
      self.organization = Entity.new(:tag => entity)
    end
  end
  #end temp
end
