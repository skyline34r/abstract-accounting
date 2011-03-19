class Ability
  include CanCan::Ability

  def initialize(user)
    i = 0
    while i < Role.count
      if user.role? Role.all[i].name
        Role.all[i].pages.each_line(',') do |p|
          can :manage, eval(p.chomp(','))
        end
      end
      i += 1
    end
  end
end
