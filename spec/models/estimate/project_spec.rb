# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Estimate::Project do

  it "should have next behaviour" do
    should validate_presence_of :place_id
    should validate_presence_of :customer_id
    should validate_presence_of :customer_type
    should belong_to :customer
    should belong_to :place
    should have_many Estimate::Project.versions_association_name
    should have_many :locals
    should have_many(:machinery).through :locals
    should have_many(:materials).through :locals
  end

  it 'should sort projects' do
    10.times { create(:project) }

    pr = Estimate::Project.sort_by_place_tag('asc')
    pr_test = Estimate::Project.joins{place}.order('places.tag asc')
    pr.should eq pr_test
    pr = Estimate::Project.sort_by_place_tag('desc')
    pr_test = Estimate::Project.joins{place}.order('places.tag desc')
    pr.should eq pr_test

    query = "case customer_type
                  when 'Entity'      then entities.tag
                  when 'LegalEntity' then legal_entities.name
             end"
    pr = Estimate::Project.sort_by_customer_tag('asc')
    pr_test = Estimate::Project.joins{customer(Entity).outer}.
        joins{customer(LegalEntity).outer}.order("#{query} asc")
    pr.should eq pr_test
    pr = Estimate::Project.sort_by_customer_tag('desc')
    pr_test = Estimate::Project.joins{customer(Entity).outer}.
        joins{customer(LegalEntity).outer}.order("#{query} desc")
    pr.should eq pr_test
  end

  it 'should build_params params' do
    legal = create :legal_entity
    place = create :place
    params = { project: {
      customer_id: legal.id,
      customer_type: LegalEntity.name,
      place_id: place.id,
      boms_catalog: {
          id: 1
      },
      prices_catalog: {
          id: 1
      }
    }}
    Estimate::Project.build_params(params).should eq ({
        customer_id: legal.id,
        customer_type: LegalEntity.name,
        place_id: place.id,
        boms_catalog_id: 1,
        prices_catalog_id: 1
    })

    params = { project: {
        customer_id: nil,
        customer_type: LegalEntity.name,
        place_id: nil,
        legal_entity: {
            tag: legal.tag,
            identifier_value: legal.identifier_value
        },
        place: {tag: place.tag},
        boms_catalog: {
            id: 1
        },
        prices_catalog: {
            id: 1
        }
    }}
    Estimate::Project.build_params(params).should eq ({
        customer_id: legal.id + 1,
        customer_type: LegalEntity.name,
        place_id: place.id,
        boms_catalog_id: 1,
        prices_catalog_id: 1
    })

    params = { project: {
        customer_id: nil,
        customer_type: LegalEntity.name,
        place_id: place.id,
        legal_entity: {
            tag: legal.tag,
            identifier_value: legal.identifier_value
        },
        boms_catalog: {
            id: 1
        },
        prices_catalog: {
            id: 1
        }
    }}
    Estimate::Project.build_params(params).should eq ({
        customer_id: legal.id + 1,
        customer_type: LegalEntity.name,
        place_id: place.id,
        boms_catalog_id: 1,
        prices_catalog_id: 1
    })

    params = { project: {
        customer_id: nil,
        customer_type: LegalEntity.name,
        place_id: place.id,
        legal_entity: {
            tag: 'legal.tag',
            identifier_value: 'legal.identifier_value'
        },
        boms_catalog: {
            id: 1
        },
        prices_catalog: {
            id: 1
        }
    }}
    Estimate::Project.build_params(params).should eq ({
        customer_id: legal.id + 2,
        customer_type: LegalEntity.name,
        place_id: place.id,
        boms_catalog_id: 1,
        prices_catalog_id: 1
    })

    entity = create :entity
    params = { project: {
        customer_id: nil,
        customer_type: Entity.name,
        place_id: place.id,
        entity: {
            tag: entity.tag,
        } ,
        boms_catalog: {
            id: 1
        },
        prices_catalog: {
            id: 1
        }
    }}
    Estimate::Project.build_params(params).should eq ({
        customer_id: entity.id,
        customer_type: Entity.name,
        place_id: place.id,
        boms_catalog_id: 1,
        prices_catalog_id: 1
    })

    params = { project: {
        customer_id: nil,
        customer_type: Entity.name,
        place_id: place.id,
        entity: {
            tag: 'entity.tag',
        },
        boms_catalog: {
            id: 1
        },
        prices_catalog: {
            id: 1
        }
    }}
    Estimate::Project.build_params(params).should eq ({
        customer_id: entity.id + 1,
        customer_type: Entity.name,
        place_id: place.id,
        boms_catalog_id: 1,
        prices_catalog_id: 1
    })

    params = { project: {
        customer_id: entity.id,
        customer_type: Entity.name,
        place_id: place.id,
        boms_catalog: {
            id: 1
        },
        prices_catalog: {
            id: 1
        }
    }}
    Estimate::Project.build_params(params).should eq ({
        customer_id: entity.id,
        customer_type: Entity.name,
        place_id: place.id,
        boms_catalog_id: 1,
        prices_catalog_id: 1
    })
  end

  it 'should return resources' do
    proj = create :project
    local1 = create(:local, project_id: proj.id)
    local2 = create(:local, project_id: proj.id)
    bom = create(:bo_m, bom_type: 1, amount: 50)
    create(:bo_m, bom_type: 2, parent_id: bom.id, amount: 60)
    local1.items.create(price_id: create(:price, bo_m_id: bom.id).id, amount: 10)
    local1.save.should be_true
    local2.items.create(price_id: create(:price, bo_m_id: bom.id).id, amount: 10)
    local2.save.should be_true
    proj.resources(:machinery).should eq proj.machinery.group{resource_id}.
                                              group{uid}.select{resource_id}.select{uid}.
                                              select{sum(amount * estimate_local_elements.amount).as :amount}
    proj.resources(:machinery)[0].amount.should eq 1200
  end
end
