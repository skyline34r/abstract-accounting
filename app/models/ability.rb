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
            where = "versions.event='create' AND versions.whodunnit IN (?)"
            if credential.place and clazz.column_names.include?("place_id")
              where += " AND place_id = #{credential.place.id}"
            end
            if credential.work and clazz.column_names.include?("work_id")
              where += " AND work_id = #{credential.work.id}"
            end
            scope = clazz.joins(clazz.versions_association_name).
                          joins("LEFT JOIN direct_accesses AS da ON da.item_id = #{clazz.table_name}.id AND da.item_type = '#{clazz.name}'").
                          where("(#{where}) OR (da.id IS NOT NULL)", users)#clazz.created_by_many(users)
            can sym_action, clazz, scope do |obj|
              if credential.place and clazz.column_names.include?("place_id") and obj.place_id != credential.place_id
                false
              elsif credential.work and clazz.column_names.include?("work_id") and obj.work_id != credential.work_id
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
