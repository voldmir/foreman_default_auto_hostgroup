class Setting::DefaultAutoHostgroup < ::Setting
  BLANK_ATTRS.concat(%w{hosts_to_exclude default_name_hostgroup fact_name_match})

  def self.load_defaults
    return unless ActiveRecord::Base.connection.table_exists?("settings")
    return unless super

    Setting.transaction do
      [
        self.set("enable_auto_hostgroup", _("Enable host group mapping."), false),
        self.set("fact_name_match", _("Fact name to match"), ""),
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
