require 'test_helper'

module PaperTrail
  module Model
    module InstanceMethods
      def create_initial_pt_version
        record_create if versions.blank?
      end
    end
  end
end

class JournalTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "check journal convertion to paper trail" do
    assert_equal 0, Journal.all.count, "Wrong journal records count"
    assert_equal 0, Version.all.count, "Wrong versions count"

    PaperTrail.enabled = false

    u = User.new(:email => "test@mail.com",
                 :password => "test_pass",
                 :password_confirmation => "test_pass",
                 :entity_id => entities(:sergey).id,
                 :role_ids => [roles(:operator).id])
    assert u.save, "User can't be saved"
    User.current = entities(:sergey)

    assert Place.new(:tag => "Some test place").save, "Entity not saved"
    wb = Waybill.new(:owner => entities(:sergey),
      :document_id => "128345",
      :place => Place.find_by_tag("Some test place"),
      :from => "Some organization",
      :created => DateTime.civil(2011, 4, 4, 12, 0, 0))
    wb.add_resource assets(:sonyvaio).tag, "th", 10
    assert wb.save, "Waybill is not saved"

    assert_equal 2, Journal.all.count, "Wrong journal records count"
    assert_equal 0, Version.all.count, "Wrong versions count"
    PaperTrail.enabled = true

    Fact.paper_trail_off
    ActiveRecord::Base.descendants.each do |model|
      if model.methods.include?(:paper_trail_enabled_for_model)
        model.all.each do |record|
          record.create_initial_pt_version
        end
      end
    end
    Fact.paper_trail_on

    Journal.find_each do |j|
      j.fact.versions.create :event => 'create',
                             :whodunnit => User.find_by_entity_id(j.created_by_id).id,
                             :created_at => j.created_at
    end
    Fact.find_each do |f|
      assert_equal 1, f.versions.count, "Wrong versions count"
      assert_equal Journal.find_by_fact_id(f.id).created_at, f.versions.first.created_at, "Wrong version created at"
      assert_equal User.find_by_entity_id(Journal.find_by_fact_id(f.id).created_by_id).id,
                   f.versions.first.whodunnit, "Wrong user id"
      assert_equal 'create', f.versions.first.event, "Wrong event"
    end
  end
end
