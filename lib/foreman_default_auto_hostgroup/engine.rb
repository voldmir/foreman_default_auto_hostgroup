module ForemanDefaultAutoHostgroup
  class Engine < ::Rails::Engine
    engine_name "foreman_default_auto_hostgroup"

    config.autoload_paths += Dir["#{config.root}/app/models"]

    initializer "foreman_default_auto_hostgroup.load_default_settings",
                before: :load_config_initializers do
      require_dependency File.expand_path(
        "../../../app/models/setting/default_auto_hostgroup.rb", __FILE__
      )
    end

    initializer "foreman_default_auto_hostgroup.register_gettext",
                :after => :load_config_initializers do
      locale_dir = File.join(File.expand_path("../..", __dir__), "locale")
      locale_domain = "foreman_default_auto_hostgroup"

      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end

    initializer "foreman_default_auto_hostgroup.register_plugin",
                before: :finisher_hook do
      Foreman::Plugin.register :foreman_default_auto_hostgroup do
        requires_foreman ">= 1.24"
      end
    end

    config.to_prepare do
      begin
        ::Host::Base.send(:include, ForemanDefaultAutoHostgroup::HostBase)
        ::Host::Managed.send(:prepend, ForemanDefaultAutoHostgroup::HostManaged)
      rescue StandardError => e
        Rails.logger.warn "ForemanDefaultAutoHostgroup: skipping engine hook (#{e})"
      end
    end
  end
end
