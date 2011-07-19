namespace :versions do
  desc 'create version for existing data'
  task :create => :environment do
    module PaperTrail
      module Model
        module InstanceMethods
          def create_initial_pt_version
            record_create if versions.blank?
            puts "Version created for class #{self.class} with id #{self.id}"
          end
        end
      end
    end

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
      puts "Create for fact #{j.fact.id} by journal" if j.fact.versions.blank?
      j.fact.versions.create(:event => 'create',
                             :whodunnit => User.find_by_entity_id(j.created_by_id).id,
                             :created_at => j.created_at) if j.fact.versions.blank?
    end
  end
end