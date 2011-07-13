class User < ActiveRecord::Base
  has_paper_trail

  has_and_belongs_to_many :roles
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :rememberable, :trackable, :recoverable,
         :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation,
                  :remember_me, :role_ids, :entity_id
  belongs_to :entity
  belongs_to :place
  validates :entity_id, :presence => true

  def role?(role)
    return !!self.roles.find_by_name(role.to_s)
  end

  def User.current
    Thread.current[:user]
  end

  def User.current=(user)
    Thread.current[:user] = user
  end
end
