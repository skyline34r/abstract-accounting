class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    else
      user.credentials.each do |credential|
        can credential.actions.collect { |item| item.to_sym }, credential.document_type.singularize.constantize
      end unless user.credentials.empty?
    end
  end
end
