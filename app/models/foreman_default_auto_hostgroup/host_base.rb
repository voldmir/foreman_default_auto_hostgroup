module ForemanDefaultAutoHostgroup
  module HostBase
    extend ActiveSupport::Concern

    def import_facts(facts, source_proxy = nil)
      result = super(facts, source_proxy)

      return result unless settings_exist?
      return result unless host_new_or_forced?
      return result unless host_has_no_hostgroup_or_forced?
      return result unless facts_hash[Setting[:fact_name_match]].present?

      return result if Setting[:hosts_to_exclude].map {|r| Regexp.new(r).match?(hostname) }.include?(true)

      new_hostgroup = find_hostgroup()

      return result unless new_hostgroup
      return result if self.hostgroup == new_hostgroup

      self.hostgroup = new_hostgroup
      if Setting[:force_host_environment] == true
        self.environment = new_hostgroup.environment
      end
      save(validate: false)
      Rails.logger.info "DefaultAutoHostgroupMatch: #{hostname} added to #{new_hostgroup}"

      result
    end

    def find_hostgroup()
      keys_search = {
        'parameters.name': Setting[:parameter_name_hostgroup],
        'parameters.searchable_value': facts_hash[Setting[:fact_name_match]],
        'parameters.key_type': "string",
        'parameters.type': "GroupParameter",
      }

      hg = Hostgroup.joins(:group_parameters).where(keys_search).first
      return hg if hg.present?

      hg = Hostgroup.where(sanitize_sql_for_conditions(['name=%s', Setting[:default_name_hostgroup]])).first
      return hg if hg.present?

      Rails.logger.info "No match hostgroup..."
      false
    end

    def settings_exist?
      unless Setting[:parameter_name_hostgroup] && Setting[:fact_name_match]
        Rails.logger.warn "DefaultAutoHostgroupMatch: Could not load :default_hostgroup map from Settings."
        return false
      end
      true
    end

    def host_new_or_forced?
      if Setting[:force_hostgroup_match_only_new]
        new_host = ((Time.current - created_at) < 300)
        unless new_host && self.hostgroup.nil? && reports.empty?
          Rails.logger.debug "DefaultAutoHostgroupMatch: skipping, host exists"
          return false
        end
      end
      true
    end

    def host_has_no_hostgroup_or_forced?
      unless Setting[:force_hostgroup_match]
        if self.hostgroup.present?
          Rails.logger.debug "DefaultAutoHostgroupMatch: skipping, host has hostgroup"
          return false
        end
      end
      true
    end
  end
end
