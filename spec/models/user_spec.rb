# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe User do
  it "should have next behaviour" do
    Factory(:user)
    should validate_presence_of :email
    should validate_presence_of :entity_id
    should validate_uniqueness_of(:email).scoped_to(:entity_id)
    should validate_format_of(:email).not_with("test@test").with_message(/invalid/)
    should ensure_length_of(:password).is_at_least(6)
    should allow_mass_assignment_of(:email)
    should allow_mass_assignment_of(:password)
    should allow_mass_assignment_of(:password_confirmation)
    should allow_mass_assignment_of(:entity)
    should_not allow_mass_assignment_of(:crypted_password)
    should_not allow_mass_assignment_of(:salt)
    should belong_to(:entity)
    should have_many User.versions_association_name
    User.new.admin?.should be_false
    should have_and_belong_to_many(:groups)
    should have_many(:credentials)
    should have_many(:accesses).class_name(DirectAccess)
    should have_many(:managed_groups).class_name(Group)
    should have_many(:managed_users).class_name(User).through(:managed_groups)

    authenticated_from_config
    check_remember_me
    check_password_reset
    check_subordinates
  end

  def authenticated_from_config
    config = YAML::load(File.open("#{Rails.root}/config/application.yml"))
    user = User.authenticate(config["defaults"]["admin"]["email"], config["defaults"]["admin"]["password"])
    user.should_not be_nil
  end

  def check_remember_me
    user = Factory(:user)
    expect { user.remember_me! }.to change{user.remember_me_token}.from(nil)
    user = Factory(:user)
    expect { user.remember_me! }.to change{user.remember_me_token_expires_at}.from(nil)
  end

  def check_password_reset
    user = Factory(:user)
    new_user = User.load_from_reset_password_token(user.reset_password_token)
    new_user.should eq(user)
    new_user.change_password!("changed")
    new_user.crypted_password.should_not eq(user.crypted_password)
  end

  def check_subordinates
    group = Factory(:group)
    group.users = (1..3).collect { Factory(:user) }
    group1 = Factory(:group, :manager => group.users.first)
    group1.users = (1..4).collect { Factory(:user) }
    group2 = Factory(:group, :manager => group.users.last)
    group2.users = (1..3).collect { Factory(:user) }
    group3 = Factory(:group, :manager => group1.users.first)
    group3.users = (1..10).collect { Factory(:user) }
    (group1.users | group3.users).should =~ group1.manager.subordinates
    group2.users.should =~ group2.manager.subordinates
    (group.users | group1.users | group2.users | group3.users).should =~
        group.manager.subordinates
    group4 = Factory(:group, :manager => group1.users.first)
    group4.users = (1..5).collect { Factory(:user) }
    (group1.users | group3.users | group4.users).should =~ group1.manager.subordinates
    (group.users | group1.users | group2.users | group3.users | group4.users).should =~
        group.manager.subordinates
  end
end
