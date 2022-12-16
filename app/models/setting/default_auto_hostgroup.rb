class Setting::DefaultAutoHostgroup < ::Setting
  BLANK_ATTRS.concat(%w{hosts_to_exclude default_name_hostgroup parameter_name_hostgroup fact_name_match})

  def self.load_defaults
    return unless ActiveRecord::Base.connection.table_exists?("settings")
    return unless super

    Setting.transaction do
      [
        self.set("force_hostgroup_match", _("Apply hostgroup matching even if a host already has one."), false),
        self.set("force_hostgroup_match_only_new", _("Apply hostgroup matching only on new hosts"), true),
        self.set("force_host_environment", _("Apply hostgroup's environment to host even if a host already has a different one"), true),
        self.set("fact_name_match", _("Fact name to match"), ""),
        self.set("parameter_name_hostgroup", _("Parameter name hostgroup"), ""),
        self.set("default_name_hostgroup", _("Default host group"), ""),
        self.set("hosts_to_exclude", _("hosts to exclude"), []),
      ].compact.each { |s| create(s.update(category: "Setting::DefaultAutoHostgroup")) }
    end

    true
  end

  def self.humanized_category
    _("Default Auto Hostgroup")
  end
end
