# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

require "sqlite3"

# CREATE TABLE "shower" ("asset_id" INTEGER, "place_id" INTEGER);
# CREATE TABLE "assoc" ("new_id" INTEGER, "old_id" INTEGER);

#module Convert
#  class DbGetter
#    include Singleton
#
#    attr_reader :db
#
#    def initialize
#      @db = SQLite3::Database.new "#{Rails.root}/db/old.sqlite3"
#    end
#
#    def warehouse_places
#      db.execute("SELECT id, tag FROM places WHERE id IN (select DISTINCT place_id from waybills)").
#          collect { |place| {id: place[0], tag: place[1]} }
#    end
#
#    def warehouse(place_id)
#      db.execute("
#        SELECT assets.id, assets.tag, products.unit, states.amount FROM states
#          INNER JOIN deals ON deals.id = states.deal_id
#          INNER JOIN assets ON deals.give_id = assets.id AND deals.give_type = 'Asset'
#          INNER JOIN products ON products.resource_id = assets.id
#          LEFT JOIN shower ON shower.asset_id = assets.id AND shower.place_id = #{place_id}
#        WHERE states.deal_id IN (
#          SELECT rules.to_id FROM rules
#          WHERE rules.deal_id IN (
#            SELECT deal_id FROM waybills
#            WHERE waybills.place_id = #{place_id} AND waybills.disable_deal_id IS NULL
#          )
#          GROUP BY rules.to_id
#        ) AND states.paid IS NULL AND states.side = 'passive' AND shower.asset_id IS NULL
#      ").collect { |warehouse| {id: warehouse[0], tag: warehouse[1], mu: warehouse[2], amount: warehouse[3]} }
#    end
#
#    def resource(id)
#      db.execute("SELECT assets.id, assets.tag, products.unit FROM assets
#                    INNER JOIN products ON products.resource_id = assets.id
#                  WHERE assets.id = #{id}").
#          collect { |resource| {id: resource[0], tag: resource[1], mu: resource[2]} }[0]
#    end
#
#    def place(id)
#      db.execute("SELECT id, tag FROM places WHERE id = #{id}").
#          collect { |place| {id: place[0], tag: place[1]} }[0]
#    end
#
#    def waybills_by_resource_id_and_place_id_and_count(resource_id, place_id, count)
#      ws = []
#      db.execute("SELECT waybills.id, rules.rate FROM rules
#                    INNER JOIN deals ON deals.id = rules.to_id
#                    INNER JOIN waybills ON waybills.deal_id = rules.deal_id
#                  WHERE deals.give_id = #{resource_id} AND deals.give_type = 'Asset' AND waybills.place_id = #{place_id}
#                  ORDER BY waybills.created DESC, waybills.id DESC").
#          collect { |info| {id: info[0], amount: info[1]} }.each do |info|
#        count -= info[:amount].to_f
#        w = db.execute("select id, created, document_id from waybills where id = #{info[:id]}")[0]
#        ws << { id: w[0], created: w[1], document_id: w[2],
#                count: (count > 0.0 ? info[:amount].to_f : (info[:amount].to_f + count)), price: 0.0 }
#        if count <= 0
#          break
#        end
#      end
#      ws
#    end
#
#    def waybill(id)
#      db.execute("SELECT id, created, document_id, vatin, from_id FROM waybills
#                  WHERE waybills.id = #{id}").
#          collect { |w| {id: w[0], created: w[1], document_id: w[2],
#                         vatin: w[3], distributor_id: w[4]} }[0]
#    end
#
#    def legal_entity(id)
#      db.execute("SELECT id, tag FROM entities
#                  WHERE entities.id = #{id}").
#          collect { |le| {id: le[0], name: le[1]} }[0]
#    end
#
#    def add_to_shower(asset_id, place_id)
#      db.execute("INSERT INTO shower(asset_id, place_id) VALUES(#{asset_id}, #{place_id})")
#    end
#
#    def add_to_assoc(new_id, old_id)
#      db.execute("INSERT INTO assoc(new_id, old_id) VALUES(#{new_id}, #{old_id})")
#    end
#
#    def get_new_id(old_id)
#      new_ids = db.execute("SELECT new_id FROM assoc WHERE old_id = #{old_id}")
#      return nil if new_ids.empty?
#      new_ids[0][0]
#    end
#
#    def self.current_users
#      Credential.where{document_type == Waybill.name}.map(&:user)
#    end
#  end
#
#  class ResourceAdder
#    attr_reader :place_id, :resource_id, :count
#
#    def initialize(attrs = {})
#      @place_id = attrs[:place_id].to_i
#      @resource_id = attrs[:resource_id].to_i
#      @count = attrs[:count].to_f
#      if attrs[:waybills]
#        @user_id = attrs[:user_id].to_i
#        @document_id = attrs[:document_id]
#        @resource_tag = attrs[:resource_tag]
#        @resource_mu = attrs[:resource_mu]
#        @waybills = []
#        attrs[:waybills].each do |w|
#          @waybills << w
#        end
#      end
#    end
#
#    def resource
#      DbGetter.instance.resource(@resource_id)
#    end
#
#    def place
#      DbGetter.instance.place(@place_id)
#    end
#
#    def waybills
#      DbGetter.instance.waybills_by_resource_id_and_place_id_and_count(@resource_id, @place_id, @count)
#    end
#
#    def save
#      throw "Unknown user_id" if @user_id <= 0
#      @waybills.each do |w|
#        throw "Should exist waybill data" if w[:amount].to_f <= 0.0 || w[:price].to_f <= 0.0 || w[:vatin].empty? || w[:document_id].empty?
#      end
#      pp @resource_tag
#      pp @resource_mu
#      Waybill.transaction do
#        user = User.find(@user_id)
#        place = user.credentials.where{document_type == Waybill.name}.first.place
#        moscow = Place.find_or_create_by_tag("Moscow")
#        @waybills.each do |w|
#          old_w = DbGetter.instance.waybill(w[:id])
#          if Convert::DbGetter.instance.get_new_id(w[:id]).nil?
#            new_w = Waybill.new(created: old_w[:created], document_id: w[:document_id],
#                                storekeeper_type: Entity.name, storekeeper_id: user.entity.id,
#                                storekeeper_place_id: place.id, distributor_place_id: moscow.id)
#            old_d = DbGetter.instance.legal_entity(old_w[:distributor_id])
#            unless new_w.distributor
#              country = Country.find_or_create_by_tag(:tag => "Russian Federation")
#              distributor = LegalEntity.find_all_by_name_and_country_id(
#                  old_d[:name], country).first
#              if distributor.nil?
#                distributor = LegalEntity.new(name: old_d[:name],
#                                              identifier_name: "VATIN",
#                                              identifier_value: w[:vatin])
#                distributor.country = country
#                distributor.save!
#              end
#              new_w.distributor = distributor
#            end
#            new_w.add_item(tag: @resource_tag, mu: @resource_mu, amount: w[:amount].to_f, price: w[:price].to_f)
#            new_w.save!
#            DbGetter.instance.add_to_assoc(new_w.id, w[:id])
#          else
#            new_w = Waybill.find(Convert::DbGetter.instance.get_new_id(w[:id]))
#            deal = new_w.deal
#            resource = Asset.find_or_create_by_tag_and_mu(@resource_tag, @resource_mu)
#            new_w.items
#            item = WaybillItem.new(object: new_w, amount: w[:amount],
#                                      resource: resource, price: w[:price])
#            new_w.instance_eval do
#              @items << item
#            end
#            from_item = item.warehouse_deal(Chart.first.currency,
#                        new_w.distributor_place, new_w.distributor)
#            throw "Cann't save from" if from_item.nil?
#
#            to_item = item.warehouse_deal(nil,
#                new_w.storekeeper_place, new_w.storekeeper)
#            throw "Cann't save to" if to_item.nil?
#
#            throw "Cann't save rules" if deal.rules.create(tag: "#{deal.tag}; rule#{deal.rules.count}",
#              from: from_item, to: to_item, fact_side: false,
#              change_side: true, rate: item.amount).nil?
#          end
#        end
#        DbGetter.instance.add_to_shower(@resource_id, @place_id)
#      end
#    end
#  end
#end

describe "converter for old db" do
  before(:all) do
    create(:chart)
  end

  it "should create new waybill" do

    place_id, resource_id, count = nil, nil, nil
    resource2_id, count2 = nil, nil

    hs = {}

    Convert::DbGetter.instance.warehouse_places.each do |w_place|
      place_id = w_place[:id]
      Convert::DbGetter.instance.warehouse(place_id).each do |w_resource|
        Convert::DbGetter.instance.waybills_by_resource_id_and_place_id_and_count(
          w_resource[:id], place_id, w_resource[:amount]).each do |waybill|
          if hs.has_key?(waybill[:id])
            resource_id, count = hs[waybill[:id]][0], hs[waybill[:id]][1]
            resource2_id, count2 = w_resource[:id], w_resource[:amount]
            break
          else
            hs[waybill[:id]] = [w_resource[:id], w_resource[:amount]]
          end
        end
        break if resource_id
      end
      break if resource_id
    end

    resource_id.should_not be_nil
    resource2_id.should_not be_nil

    user = create(:user)
    create(:credential, user: user, document_type: Waybill.name)

    resource = Convert::DbGetter.instance.resource(resource_id)
    waybills = Convert::DbGetter.instance.waybills_by_resource_id_and_place_id_and_count(
        resource_id, place_id, count
    ).collect do |item|
      vatin = Convert::DbGetter.instance.waybill(item[:id])[:vatin]
      vatin = "12345dsfs" if vatin.empty?
      {id: item[:id], document_id: item[:document_id],
       amount: item[:count], price: 23.34, vatin: vatin }
    end
    params = {
        place_id: place_id, resource_id: resource_id, count: count,
        user_id: user.id, resource_tag: resource[:tag], resource_mu: resource[:mu],
        waybills: waybills
    }

    adder = Convert::ResourceAdder.new(params)
    adder.save

    Waybill.count.should eq(waybills.count)
    waybills.each do |old_w1|
      old_w = Convert::DbGetter.instance.waybill(old_w1[:id])
      w = Waybill.find_by_document_id(old_w[:document_id])
      w.should_not be_nil
      w.storekeeper.id.should eq(user.entity.id)
      w.storekeeper_place.id.should eq(user.credentials.first.place_id)
      old_d = Convert::DbGetter.instance.legal_entity(old_w[:distributor_id])
      w.distributor.should be_instance_of(LegalEntity)
      w.distributor.name.should eq(old_d[:name])
      w.distributor.country.tag.should eq("Russian Federation")
      w.distributor.identifier_name.should eq("VATIN")
      w.distributor.identifier_value.should eq(old_w1[:vatin])
      w.distributor_place.tag.should eq("Moscow")
      w.items.count.should eq(1)
      w.items[0].resource.tag.should eq(params[:resource_tag])
      w.items[0].resource.mu.should eq(params[:resource_mu])
      w.items[0].amount.should eq(old_w1[:amount])
      w.items[0].price.should eq(old_w1[:price])
    end

    Convert::DbGetter.instance.warehouse(place_id).collect { |item| item[:id] }.index(resource_id).should be_nil

    old_count = Waybill.count

    adder = Convert::ResourceAdder.new(resource_id: resource2_id, place_id: place_id,
                                       count: count2)
    waybills = adder.waybills.collect do |item|
          vatin = Convert::DbGetter.instance.waybill(item[:id])[:vatin]
          {id: item[:id], document_id: item[:document_id],
           amount: item[:count], price: 23.34, vatin: vatin }
        end
    found = false
    waybills.each do |w|
      unless Convert::DbGetter.instance.get_new_id(w[:id]).nil?
        w[:document_id].should eq(Waybill.find(Convert::DbGetter.instance.get_new_id(w[:id])).document_id)
        w[:vatin] = Waybill.find(Convert::DbGetter.instance.get_new_id(w[:id])).distributor.identifier_value
        found = true
      end
    end
    found.should be_true
    params = {
        place_id: place_id, resource_id: resource2_id, count: count2,
        user_id: user.id, resource_tag: adder.resource[:tag], resource_mu: adder.resource[:mu],
        waybills: waybills
    }

    adder = Convert::ResourceAdder.new(params)
    adder.save

    Waybill.count.should_not eq(waybills.count + old_count)
    waybills.each do |old_w1|
      unless Convert::DbGetter.instance.get_new_id(old_w1[:id]).nil?
        w = Waybill.find(Convert::DbGetter.instance.get_new_id(old_w1[:id]))
        w.items.count.should eq(2)
        w.items.each do |it|
          if it.resource.tag == params[:resource_tag]
            it.resource.tag.should eq(params[:resource_tag])
            it.resource.mu.should eq(params[:resource_mu])
            it.amount.should eq(old_w1[:amount])
            it.price.should eq(old_w1[:price])
            break
          end
        end
      end
    end

    Convert::DbGetter.instance.warehouse(place_id).collect { |item| item[:id] }.index(resource2_id).should be_nil

    db = SQLite3::Database.new "#{Rails.root}/db/old.sqlite3"
    db.execute("DELETE FROM shower")
  end
end
