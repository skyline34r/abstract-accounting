# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

feature "waybill", %q{
  As an user
  I want to manage waybills
}do

  scenario "manage waybills", :js => true do
    page_login

    page.find("#btn_create").click
    page.find("a[@href='#documents/waybills/new']").click
    page.should have_xpath("//ul[@id='documents_list' and contains(@style, 'display: none')]")

    current_hash.should eq("documents/waybills/new")
    page.should have_selector("div[@id='container_documents'] form")
    page.should have_selector("input[@value='Save']")
    page.should have_selector("input[@value='Cancel']")
    page.should have_selector("input[@value='Draft']")
    page.find_by_id("inbox")[:class].should_not eq("sidebar-selected")

    page.should have_xpath("//div[@id='ui-datepicker-div']")
    page.find("#created").click
    page.should have_xpath("//div[@id='ui-datepicker-div' and contains(@style, 'display: block')]")
    page.find("#container_documents").click
    page.should have_xpath("//div[@id='ui-datepicker-div' and contains(@style, 'display: none')]")

    page.find("#created").click
    page.find("#ui-datepicker-div table[@class='ui-datepicker-calendar'] tbody tr td a").click

    page.should have_selector("input[@id='waybill_document_id']")
    fill_in("waybill_document_id", :with => "1233321")

    within("#container_documents form") do
      items = 6.times.collect { Factory(:legal_entity) } .sort
      check_autocomplete("waybill_entity", items, :name) do |entity|
        find("#waybill_ident_name")["value"].should eq(entity ? entity.identifier_name : "")
        find("#waybill_ident_value")["value"].should eq(entity ? entity.identifier_value : "")
      end

      items = 6.times.collect { Factory(:place) } .sort
      check_autocomplete("distributor_place", items, :tag)

      check_autocomplete("storekeeper_place", items, :tag)

      items = 6.times.collect { Factory(:entity) } .sort
      check_autocomplete("storekeeper_entity", items, :tag)

      page.should have_xpath("//table[@id='estimate_boms']")
      page.should_not have_selector(:xpath, "//table[@id='estimate_boms']//tbody//tr")
      page.find(:xpath, "//fieldset[@class='with-legend']//input[@value='Add']").click
      page.should have_selector(:xpath, "//table[@id='estimate_boms']//tbody//tr")
      page.should have_selector(:xpath, "//table[@id='estimate_boms']//tbody//tr//td[@class='estimate-boms-actions']")
      fill_in("tag_0", :with => "tag")
      fill_in("mu_0", :with => "mu")
      fill_in("count_0", :with => "0")
      fill_in("price_0", :with => "0")
      page.find("table[@id='estimate_boms'] thead tr").click
      page.find("#tag_0")["value"].should eq("tag")
      page.find("#mu_0")["value"].should eq("mu")
      page.find("#count_0")["value"].should eq("0")
      page.find("#price_0")["value"].should eq("0")
      page.find("table[@id='estimate_boms'] tbody tr td[@class='estimate-boms-actions'] label").click
      page.has_no_selector?("#tag_0").should be_true
      page.has_no_selector?("#mu_0").should be_true
      page.has_no_selector?("#count_0").should be_true
      page.has_no_selector?("#price_0").should be_true
      page.should_not have_selector("table[@id='estimate_boms'] tbody tr")

      page.find(:xpath, "//fieldset[@class='with-legend']//input[@value='Add']").click
      fill_in("tag_0", :with => "tag_1")
      fill_in("mu_0", :with => "RUB")
      fill_in("count_0", :with => "10")
      fill_in("price_0", :with => "100")
    end
    lambda {
      page.find(:xpath, "//div[@class='actions']//input[@value='Save']").click
      page.should have_selector("#inbox[@class='sidebar-selected']")
    }.should change(Waybill, :count).by(1)
  end
end
