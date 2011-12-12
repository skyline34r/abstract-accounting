class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    else
      user.credentials(:force_update).each do |credential|
        clazz = credential.document_type.singularize.constantize
        credential.actions.each do |action|
          sym_action = action.to_sym
          if sym_action == :read
            users = user.subordinates << user
            scope = clazz.created_by_many(users)
            if credential.place and clazz.column_names.include?("place_id")
              scope = scope.where("place_id = ?", credential.place)
            end
            can sym_action, clazz, scope do |obj|
              if credential.place and clazz.column_names.include?("place_id") and obj.place_id != credential.place_id
                false
              else
                versions = obj.versions.creations
                if versions.empty?
                  false
                else
                  users.collect { |usr| usr.id }.include?(versions.first.whodunnit.to_i)
                end
              end
            end
          else
            can sym_action, clazz
          end
        end
      end unless user.credentials.empty?
    end
  end
end
