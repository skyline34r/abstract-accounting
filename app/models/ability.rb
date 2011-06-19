require "storehouse"
require "storehouse_release"
require "waybill"

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
            case p.chomp(",")
              when "Storehouse"
                if user.place.nil?
                  alias_action :index, :view, :show, :releases, :list,
                               :view_release, :pdf, :return, :return_list,
                               :resource_state,:to => :storehouse_read
                  can :storehouse_read, [Storehouse, Waybill, StorehouseRelease, StorehouseReturn]
                else
                  can :manage, [Storehouse, Waybill, StorehouseRelease, StorehouseReturn]
                end
              when "Taskmaster"
                alias_action :return, :return_list, :return_resources,
                             :resource_state, :to => :taskmaster
                can :manage, StorehouseReturn
                can :taskmaster, Storehouse
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
