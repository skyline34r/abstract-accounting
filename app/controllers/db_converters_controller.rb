# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details
require "sqlite3"

module Convert
  class DbGetter
    include Singleton

    attr_reader :db

    def initialize
      @db = SQLite3::Database.new "#{Rails.root}/db/old.sqlite3"
    end

    def warehouse_places
      db.execute("SELECT id, tag FROM places WHERE id IN (select DISTINCT place_id from waybills)").
          collect { |place| {id: place[0], tag: place[1]} }
    end

    def warehouse(place_id)
      db.execute("
        SELECT assets.id, assets.tag, products.unit, states.amount FROM states
          INNER JOIN deals ON deals.id = states.deal_id
          INNER JOIN assets ON deals.give_id = assets.id AND deals.give_type = 'Asset'
          INNER JOIN products ON products.resource_id = assets.id
          LEFT JOIN shower ON shower.asset_id = assets.id AND shower.place_id = #{place_id}
        WHERE states.deal_id IN (
          SELECT rules.to_id FROM rules
          WHERE rules.deal_id IN (
            SELECT deal_id FROM waybills
            WHERE waybills.place_id = #{place_id} AND waybills.disable_deal_id IS NULL
          )
          GROUP BY rules.to_id
        ) AND states.paid IS NULL AND states.side = 'passive' AND shower.asset_id IS NULL
      ").collect { |warehouse| {id: warehouse[0], tag: warehouse[1], mu: warehouse[2], amount: warehouse[3]} }
    end

    def resource(id)
      db.execute("SELECT assets.id, assets.tag, products.unit FROM assets
                    INNER JOIN products ON products.resource_id = assets.id
                  WHERE assets.id = #{id}").
          collect { |resource| {id: resource[0], tag: resource[1], mu: resource[2]} }[0]
    end

    def place(id)
      db.execute("SELECT id, tag FROM places WHERE id = #{id}").
          collect { |place| {id: place[0], tag: place[1]} }[0]
    end

    def waybills_by_resource_id_and_place_id_and_count(resource_id, place_id, count)
      ws = []
      db.execute("SELECT waybills.id, rules.rate FROM rules
                    INNER JOIN deals ON deals.id = rules.to_id
                    INNER JOIN waybills ON waybills.deal_id = rules.deal_id
                  WHERE deals.give_id = #{resource_id} AND deals.give_type = 'Asset' AND waybills.place_id = #{place_id}
                  ORDER BY waybills.created DESC, waybills.id DESC").
          collect { |info| {id: info[0], amount: info[1]} }.each do |info|
        count -= info[:amount].to_f
        w = db.execute("select id, created, document_id from waybills where id = #{info[:id]}")[0]
        ws << { id: w[0], created: w[1], document_id: w[2],
                count: (count > 0.0 ? info[:amount].to_f : (info[:amount].to_f + count)), price: 0.0 }
        if count <= 0
          break
        end
      end
      ws
    end

    def waybill(id)
      db.execute("SELECT id, created, document_id, vatin, from_id FROM waybills
                  WHERE waybills.id = #{id}").
          collect { |w| {id: w[0], created: w[1], document_id: w[2],
                         vatin: w[3], distributor_id: w[4]} }[0]
    end

    def legal_entity(id)
      db.execute("SELECT id, tag FROM entities
                  WHERE entities.id = #{id}").
          collect { |le| {id: le[0], name: le[1]} }[0]
    end

    def add_to_shower(asset_id, place_id)
      db.execute("INSERT INTO shower(asset_id, place_id) VALUES(#{asset_id}, #{place_id})")
    end

    def add_to_assoc(new_id, old_id)
      db.execute("INSERT INTO assoc(new_id, old_id) VALUES(#{new_id}, #{old_id})")
    end

    def get_new_id(old_id)
      new_ids = db.execute("SELECT new_id FROM assoc WHERE old_id = #{old_id}")
      return nil if new_ids.empty?
      new_ids[0][0]
    end

    def self.current_users
      Credential.where{document_type == Waybill.name}.map(&:user)
    end
  end

  class ResourceAdder
    attr_reader :place_id, :resource_id, :count

    def initialize(attrs = {})
      @place_id = attrs[:place_id].to_i
      @resource_id = attrs[:resource_id].to_i
      @count = attrs[:count].to_f
      if attrs[:waybills]
        @user_id = attrs[:user_id].to_i
        @document_id = attrs[:document_id]
        @resource_tag = attrs[:resource_tag]
        @resource_mu = attrs[:resource_mu]
        @waybills = []
        attrs[:waybills].each do |w|
          @waybills << w
        end
      end
    end

    def resource
      DbGetter.instance.resource(@resource_id)
    end

    def place
      DbGetter.instance.place(@place_id)
    end

    def waybills
      DbGetter.instance.waybills_by_resource_id_and_place_id_and_count(@resource_id, @place_id, @count)
    end

    def save
      throw "Unknown user_id" if @user_id <= 0
      Waybill.transaction do
        user = User.find(@user_id)
        place = user.credentials.where{document_type == Waybill.name}.first.place
        moscow = Place.find_or_create_by_tag("Moscow")
        @waybills.each do |w|
          throw "Should exist waybill data" if w[:price].to_f <= 0.0
          old_w = DbGetter.instance.waybill(w[:id])
          if Convert::DbGetter.instance.get_new_id(w[:id]).nil?
            throw "Should exist waybill data" if w[:vatin].empty? || w[:document_id].empty?
            new_w = Waybill.new(created: old_w[:created], document_id: w[:document_id],
                                storekeeper_type: Entity.name, storekeeper_id: user.entity.id,
                                storekeeper_place_id: place.id, distributor_place_id: moscow.id)
            old_d = DbGetter.instance.legal_entity(old_w[:distributor_id])
            unless new_w.distributor
              country = Country.find_or_create_by_tag(:tag => "Russian Federation")
              distributor = LegalEntity.find_all_by_name_and_country_id(
                  old_d[:name], country).first
              if distributor.nil?
                distributor = LegalEntity.new(name: old_d[:name],
                                              identifier_name: "VATIN",
                                              identifier_value: w[:vatin])
                distributor.country = country
                distributor.save!
              end
              new_w.distributor = distributor
            end
            new_w.add_item(tag: @resource_tag, mu: @resource_mu, amount: w[:count], price: w[:price])
            new_w.save!
            DbGetter.instance.add_to_assoc(new_w.id, w[:id])
          else
            new_w = Waybill.find(Convert::DbGetter.instance.get_new_id(w[:id]))
            deal = new_w.deal
            resource = Asset.find_or_create_by_tag_and_mu(@resource_tag, @resource_mu)
            new_w.items
            item = WaybillItem.new(object: new_w, amount: w[:count],
                                      resource: resource, price: w[:price])
            new_w.instance_eval do
              @items << item
            end
            from_item = item.warehouse_deal(Chart.first.currency,
                        new_w.distributor_place, new_w.distributor)
            throw "Cann't save from" if from_item.nil?

            to_item = item.warehouse_deal(nil,
                new_w.storekeeper_place, new_w.storekeeper)
            throw "Cann't save to" if to_item.nil?

            throw "Cann't save rules" if deal.rules.create(tag: "#{deal.tag}; rule#{deal.rules.count}",
              from: from_item, to: to_item, fact_side: false,
              change_side: true, rate: item.amount).nil?
          end
        end
        DbGetter.instance.add_to_shower(@resource_id, @place_id)
      end
    end
  end
end

class DbConvertersController < ApplicationController
  def places
    @places = Convert::DbGetter.instance.warehouse_places
  end

  def warehouse
    @warehouse = Convert::DbGetter.instance.warehouse(params[:place_id])
  end

  def new
    @adder = Convert::ResourceAdder.new(place_id: params[:place_id],
                               resource_id: params[:resource_id],
                               count: params[:count])
  end

  def create
    Convert::ResourceAdder.new(params[:adder]).save()
    redirect_to warehouse_db_converters_path(place_id: params[:adder][:place_id])
  end
end
