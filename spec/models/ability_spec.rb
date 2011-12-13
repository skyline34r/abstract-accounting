# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'
require "cancan/matchers"

describe Ability do
  it "should have next behaviour" do
    Ability.new(Factory(:user)).should_not be_able_to(:manage, :all)
    Ability.new(UserAdmin.new).should be_able_to(:manage, :all)

    #check permissions
    user = Factory(:user)
    credential = user.credentials.create!(:document_type => User.name, :actions => [:create])
    Ability.new(user).should be_able_to(:create, User)
    user.credentials.create!(:document_type => Credential.name, :actions => [:update])
    Ability.new(user).should be_able_to(:create, User)
    Ability.new(user).should be_able_to(:update, Credential)
    credential.actions << :update
    credential.save!
    Ability.new(user).should be_able_to(:update, Credential)
    Ability.new(user).should be_able_to(:create, User)
    Ability.new(user).should be_able_to(:update, User)
    credential.actions = ["create", :update]
    credential.save!
    Ability.new(user).should be_able_to(:update, Credential)
    Ability.new(user).should be_able_to(:create, User)
    Ability.new(user).should be_able_to(:update, User)
    user.credentials.create!(:document_type => Group.name, :actions => [:create])
    Ability.new(user).should be_able_to(:update, Credential)
    Ability.new(user).should be_able_to(:create, Group)
    Ability.new(user).should be_able_to(:create, User)
    Ability.new(user).should be_able_to(:update, User)
    credential.actions << :read
    credential.save!
    Ability.new(user).should be_able_to(:update, Credential)
    Ability.new(user).should be_able_to(:read, User)
    Ability.new(user).should be_able_to(:create, User)
    Ability.new(user).should be_able_to(:update, User)

    #check that current user can read only objects created by current user
    credential = user.credentials.where(:document_type => Credential.name).first
    credential.actions << :read
    credential.save!
    manager = Factory(:user)
    manager.credentials.create!(:document_type => Credential.name, :actions => [:read])
    Factory(:group, :manager => manager, :users => [user])
    employee = Factory(:user)
    employee.credentials.create!(:document_type => Credential.name, :actions => [:read])
    boss = Factory(:user)
    boss.credentials.create!(:document_type => Credential.name, :actions => [:read])
    Factory(:group, :manager => boss, :users => [manager, employee])

    PaperTrail.whodunnit = user
    user_creation = (1..3).collect { Factory(:credential) }
    PaperTrail.whodunnit = employee
    employee_creation = (1..3).collect { Factory(:credential) }
    PaperTrail.whodunnit = manager
    manager_creation = (1..2).collect { Factory(:credential) }
    user_creation.should =~ Credential.accessible_by(Ability.new(user))
    employee_creation.should =~ Credential.accessible_by(Ability.new(employee))
    (manager_creation | user_creation).should =~ Credential.accessible_by(Ability.new(manager))
    (manager_creation | user_creation | employee_creation).should =~ Credential.accessible_by(Ability.new(boss))
    Ability.new(boss).should be_able_to(:read, employee_creation.first)
    Ability.new(boss).should_not be_able_to(:read, manager.credentials.first)
    Ability.new(manager).should be_able_to(:read, user_creation.first)

    #check ability by credentials place
    place = Factory(:place)
    user.credentials.where(:document_type => Credential.name).first.update_attributes :place => place
    employee.credentials.where(:document_type => Credential.name).first.update_attributes :place => place
    manager.credentials.where(:document_type => Credential.name).first.update_attributes :place => place
    PaperTrail.whodunnit = user
    user_creation_with_place = (1..3).collect { Factory(:credential, :place => place) }
    PaperTrail.whodunnit = employee
    Credential.accessible_by(Ability.new(employee)).should be_empty
    employee_creation_with_place = (1..3).collect { Factory(:credential, :place => place) }

    user_creation_with_place.should =~ Credential.accessible_by(Ability.new(user))
    user_creation_with_place.should =~ Credential.accessible_by(Ability.new(manager))
    employee_creation_with_place.should =~ Credential.accessible_by(Ability.new(employee))
    (manager_creation | user_creation | employee_creation |
    user_creation_with_place | employee_creation_with_place).should =~ Credential.accessible_by(Ability.new(boss))
    Ability.new(user).should be_able_to(:read, user_creation_with_place.first)
    Ability.new(user).should_not be_able_to(:read, user_creation.first)
    Ability.new(employee).should be_able_to(:read, employee_creation_with_place.first)

    #check ability by credentials work
    work = Factory(:work)
    user.credentials.where(:document_type => Credential.name).first.update_attributes :work => work, :place => nil
    employee.credentials.where(:document_type => Credential.name).first.update_attributes :work => work, :place => nil
    manager.credentials.where(:document_type => Credential.name).first.update_attributes :work => work, :place => nil
    PaperTrail.whodunnit = user
    user_creation_with_work = (1..3).collect { Factory(:credential, :work => work) }
    PaperTrail.whodunnit = employee
    Credential.accessible_by(Ability.new(employee)).should be_empty
    employee_creation_with_work = (1..3).collect { Factory(:credential, :work => work) }

    user_creation_with_work.should =~ Credential.accessible_by(Ability.new(user))
    user_creation_with_work.should =~ Credential.accessible_by(Ability.new(manager))
    employee_creation_with_work.should =~ Credential.accessible_by(Ability.new(employee))
    (manager_creation | user_creation | employee_creation |
    user_creation_with_place | employee_creation_with_place |
    user_creation_with_work | employee_creation_with_work).should =~ Credential.accessible_by(Ability.new(boss))
    Ability.new(user).should be_able_to(:read, user_creation_with_work.first)
    Ability.new(user).should_not be_able_to(:read, user_creation.first)
    Ability.new(employee).should be_able_to(:read, employee_creation_with_work.first)

    #check ability by credentials work and place
    manager.credentials.where(:document_type => Credential.name).first.update_attributes :work => nil, :place => nil
    (user_creation | user_creation_with_place |
        user_creation_with_work | manager_creation).should =~ Credential.accessible_by(Ability.new(manager))
    manager.credentials.where(:document_type => Credential.name).first.update_attributes :work => work, :place => place
    Credential.accessible_by(Ability.new(manager)).should be_empty
    PaperTrail.whodunnit = user
    objects_with_work_and_place = (1..3).collect { Factory(:credential, :work => work, :place => place) }
    objects_with_work_and_place.should =~ Credential.accessible_by(Ability.new(manager))

    #check ability to read by direct access
    direct_credential = Factory(:credential)
    Factory(:direct_access, :user => manager, :item => direct_credential)
    Credential.accessible_by(Ability.new(manager)).should =~ (objects_with_work_and_place << direct_credential)
  end
end
