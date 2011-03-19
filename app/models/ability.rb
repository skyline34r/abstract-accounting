class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role? :operator
      can :manage, :all
    end
  end
end
