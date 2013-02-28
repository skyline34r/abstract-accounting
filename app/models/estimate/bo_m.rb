# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

module Estimate
  class BoM < Base
    BOM = 1
    MACHINERY = 2
    MATERIALS = 3

    attr_accessible :uid, :catalog_id, :resource_id
    validates_presence_of :resource_id, :uid, :bom_type
    validates_presence_of :catalog_id, if: Proc.new { |bom| bom.bom_type == BOM }
    validates_inclusion_of :bom_type, in: [BOM, MACHINERY, MATERIALS]
    validate :empty_resources

    belongs_to :resource, class_name: "::#{Asset.name}"
    belongs_to :catalog

    has_many :items, class_name: BoM, foreign_key: :parent_id
    has_many :machinery, class_name: BoM, foreign_key: :parent_id,
             conditions: { bom_type: MACHINERY }
    has_many :materials, class_name: BoM, foreign_key: :parent_id,
             conditions: { bom_type: MATERIALS }
    has_many :prices

    delegate :tag, :mu, to: :resource

    after_initialize :initialize_bom_type

    custom_sort(:tag) do |dir|
      joins{resource}.order{resource.tag.__send__(dir)}
    end

    custom_sort(:mu) do |dir|
      joins{resource}.order{resource.mu.__send__(dir)}
    end

    custom_sort(:catalog_tag) do |dir|
      joins{catalog}.order{catalog.tag.__send__(dir)}
    end

    def empty_resources
      if self.workers_amount.nil? and self.avg_work_level.nil? and self.drivers_amount.nil? and
         self.machinery.size == 0 and self.materials.size == 0 and self.bom_type == 1
        self.errors.add(I18n.t('views.estimates.boms'), I18n.t('errors.messages.blanks'))
      end
    end

    class << self
      def create_resource(args)
        resource = Asset.with_lower_tag_eq_to(args[:tag]).with_lower_mu_eq_to(args[:mu]).first
        resource || Asset.create(args)
      end

      def with_catalog_id(cid)
        where{catalog_id == my{cid}}
      end

      def with_catalog_pid(cpid)
        children = Estimate::Catalog.find(cpid).children
        where{catalog_id.in(children)}
      end

      def only_boms
        where{bom_type == BOM}
      end
    end

    def build_machinery(args)
      if args.has_key?(:resource) && args[:resource].kind_of?(Hash)
        args[:resource][:mu] = I18n.t('views.estimates.elements.mu.machine') unless args[:resource][:mu]
        args[:resource] = BoM.create_resource(args[:resource])
      end
      self.machinery.build(uid: args[:uid], resource_id: args[:resource][:id]).amount = args[:amount]
    end

    def build_materials(args)
      if args.has_key?(:resource) && args[:resource].kind_of?(Hash)
        args[:resource] = BoM.create_resource(args[:resource])
      end
      self.materials.build(uid: args[:uid], resource_id: args[:resource][:id]).amount = args[:amount]
    end

    def save_with_items params
      BoM.transaction do
        params[:bo_m][:resource_id] ||= BoM.create_resource(params[:resource]).id
        self.resource_id = params[:bo_m][:resource_id]
        self.workers_amount = params[:bo_m][:workers_amount] if params[:bo_m][:workers_amount]
        self.avg_work_level = params[:bo_m][:avg_work_level] if params[:bo_m][:avg_work_level]
        self.drivers_amount = params[:bo_m][:drivers_amount] if params[:bo_m][:drivers_amount]
        params[:materials].values.each { |item| self.build_materials(item) } if params[:materials]
        params[:machinery].values.each { |item| self.build_machinery(item) } if params[:machinery]
        if self.save
          true
        else
          raise ActiveRecord::Rollback
          false
        end
      end
    end

    custom_search(:mu) do |value|
      joins{resource}.where{lower(resource.mu).like(lower("%#{value}%"))}
    end

    custom_search(:tags) do |value|
      joins{resource}.where do
        scope = lower(resource.tag).like(lower("%#{my{value["main"]}}%"))
        if my{value["more"]}
          my{value["more"]}.each do |item|
            tmp_scope = lower(resource.tag).like(lower("%#{item[1][:tag]}%"))
            if item[1][:type] == I18n.t('views.estimates.filter.and')
              scope = scope ? scope & tmp_scope : tmp_scope
            else
              scope = scope ? scope | tmp_scope : tmp_scope
            end
          end
        end
        scope
      end
    end

    private
      def initialize_bom_type
        self.bom_type ||= BOM if self.attributes.has_key?('bom_type')
      end
  end
end
