# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Estimate::Local do
  it "should have next behaviour" do
    should validate_presence_of :date
    should validate_presence_of :tag
    should validate_presence_of :project_id

    should belong_to :project

    should have_many Estimate::Local.versions_association_name
    should have_many(:items).class_name(Estimate::LocalElement)
    should have_many(:machinery).through :items
    should have_many(:materials).through :items
  end

  it { subject.class.should include(Helpers::Commentable) }
  it { should have_many :comments }

  it 'should return uncanceled estimates' do
    10.times { create :local }
    Estimate::Local.first.update_attribute(:canceled, DateTime.now)
    Estimate::Local.without_canceled.should eq Estimate::Local.where{canceled == nil}
  end

  it 'should apply and cancel' do
    PaperTrail.enabled = true
    PaperTrail.whodunnit = create :user
    local = create :local
    expect { local.apply.should be_true }.to change(Comment, :count).by(1)
    local.approved.should_not be_nil
    Comment.first.message.should eq I18n.t("activerecord.attributes.estimate.local.comment.apply")
    expect { local.cancel.should be_true }.to change(Comment, :count).by(1)
    local.canceled.should_not be_nil
    Comment.first.message.should eq I18n.t("activerecord.attributes.estimate.local.comment.cancel")
  end

  it 'should return resources' do
    local = create :local
    bom = create(:bo_m, bom_type: 1, amount: 50)
    create(:bo_m, bom_type: 2, parent_id: bom.id, amount: 60)
    local.items.create(price_id: create(:price, bo_m_id: bom.id).id, amount: 10)
    local.save.should be_true
    local.resources(:machinery).should eq local.machinery.group{resource_id}.
      group{uid}.select{resource_id}.select{uid}.
      select{sum(amount * estimate_local_elements.amount).as :amount}
    local.resources(:machinery)[0].amount.should eq 600
  end
end
