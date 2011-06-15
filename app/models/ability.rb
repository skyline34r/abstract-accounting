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
                               :view_release, :pdf, :to => :storehouse_read
                  can :storehouse_read, [Storehouse, Waybill, StorehouseRelease]
                else
                  can :manage, [Storehouse, Waybill, StorehouseRelease]
                end
              when "Taskmaster"
                alias_action :return, :return_list, :return_resources,
                             :to => :taskmaster
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
