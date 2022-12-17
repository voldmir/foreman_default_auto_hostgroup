module ForemanDefaultAutoHostgroup
  module HostBase
    extend ActiveSupport::Concern

    module Overrides
      def import_facts(facts, source_proxy = nil)
        result = super(facts, source_proxy)

        return result unless Setting[:enable_auto_hostgroup]
        return result unless Setting[:fact_name_match]
        return result unless facts_hash[Setting[:fact_name_match]].present?
        return result if Setting[:hosts_to_exclude].map { |r| Regexp.new(r).match?(hostname) }.include?(true)

        new_hostgroup = find_hostgroup()

        return result unless new_hostgroup
        return result if self.hostgroup == new_hostgroup

        self.hostgroup = new_hostgroup
        self.environment = new_hostgroup.environment

        save(validate: false)
        Rails.logger.info "DefaultAutoHostgroupMatch: #{hostname} added to #{new_hostgroup}"

        result
      end
    end

    included do
      prepend Overrides
    end

    def find_hostgroup()
      hg = Hostgroup.unscoped.find_by(title: facts_hash[Setting[:fact_name_match]])
      return hg if hg.present?

      hg = Hostgroup.unscoped.find_by(name: Setting[:default_name_hostgroup])
      return hg if hg.present?

      Rails.logger.info "No match hostgroup..."
      false
    end
  end
end
