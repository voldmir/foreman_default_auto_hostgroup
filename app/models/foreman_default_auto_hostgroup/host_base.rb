module ForemanDefaultAutoHostgroup
  module HostBase
    extend ActiveSupport::Concern

    module Overrides
      def import_facts(facts, source_proxy = nil)
        result = super(facts, source_proxy)

        return result unless Setting[:enable_auto_hostgroup]
        return result unless Setting[:fact_name_match]
        return result if Setting[:hosts_to_exclude].map { |r| Regexp.new(r).match?(hostname) }.include?(true)

        def_hostgroup = find_hostgroup_default()
        new_hostgroup = find_hostgroup() || def_hostgroup

        return result unless new_hostgroup

        organization = new_hostgroup.organizations.first

        if new_hostgroup.organizations.size != 1 or not organization.present?
          new_hostgroup = def_hostgroup
          organization = find_organization_default()
        end

        self.hostgroup = new_hostgroup unless self.hostgroup == new_hostgroup
        self.environment = new_hostgroup.environment unless self.environment == new_hostgroup.environment
        self.organization = organization unless self.organization == organization

        if self.changed.present?
          save(validate: false)
          Rails.logger.info "DefaultAutoHostgroupMatch: #{hostname} added to #{new_hostgroup}"
        end
        result
      end
    end

    included do
      prepend Overrides
    end

    def find_organization_default()
      Taxonomy.unscoped.find_by(name: Setting[:default_organization])
    end

    def find_hostgroup_default()
      Hostgroup.unscoped.find_by(name: Setting[:default_name_hostgroup])
    end

    def find_hostgroup()
      if facts_hash[Setting[:fact_name_match]].present?
        hg = Hostgroup.unscoped.find_by(title: facts_hash[Setting[:fact_name_match]])
        return hg if hg.present?
      end
      Rails.logger.info "No hostgroup match with fact_name_match..."
      false
    end
  end
end
