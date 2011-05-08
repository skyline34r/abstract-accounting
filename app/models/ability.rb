class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role? "admin"
      can :manage, :all
    else
      i = 0
      while i < Role.count
        if user.role? Role.all[i].name
          Role.all[i].pages.each_line(',') do |p|
            if p == "Storehouse"
              if user.place.nil?
                can :read, [StoreHouse, StorehouseRelease, Waybill,
                  StoreHouseEntry, StorehouseReleaseEntry, WaybillEntry]
              else
                can :manage, [StoreHouse, StorehouseRelease, Waybill,
                  StoreHouseEntry, StorehouseReleaseEntry, WaybillEntry]
              end
            else
              can :manage, eval(p.chomp(','))
            end
          end
        end
        i += 1
      end
    end
  end
end
