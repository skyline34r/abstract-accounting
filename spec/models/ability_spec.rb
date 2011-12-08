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
    credential = Factory(:credential, :document_type => User.name, :actions => [:create])
    user = Factory(:user, :credentials => [credential])
    Ability.new(user).should be_able_to(:create, User)
    user.credentials << Factory(:credential, :document_type => Credential.name, :actions => [:update])
    Ability.new(user).should be_able_to(:create, User)
    Ability.new(user).should be_able_to(:update, Credential)
    credential.actions << :update
    Ability.new(user).should be_able_to(:update, Credential)
    Ability.new(user).should be_able_to(:create, User)
    Ability.new(user).should be_able_to(:update, User)
    credential.actions = ["create", :update]
    Ability.new(user).should be_able_to(:update, Credential)
    Ability.new(user).should be_able_to(:create, User)
    Ability.new(user).should be_able_to(:update, User)
    user.credentials << Factory(:credential, :document_type => Group.name, :actions => [:create])
    Ability.new(user).should be_able_to(:update, Credential)
    Ability.new(user).should be_able_to(:create, Group)
    Ability.new(user).should be_able_to(:create, User)
    Ability.new(user).should be_able_to(:update, User)
    credential.actions << :read
    Ability.new(user).should be_able_to(:update, Credential)
    Ability.new(user).should be_able_to(:read, User)
    Ability.new(user).should be_able_to(:create, User)
    Ability.new(user).should be_able_to(:update, User)
  end
end
