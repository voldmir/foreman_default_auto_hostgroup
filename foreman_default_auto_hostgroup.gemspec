$LOAD_PATH.push File.expand_path("lib", __dir__)

require_relative "lib/foreman_default_auto_hostgroup/version"

Gem::Specification.new do |s|
  s.name = "foreman_default_auto_hostgroup"
  s.version = ForemanDefaultAutoHostgroup::VERSION
  s.authors = ["Vladimir Savchenko"]
  s.email = ["voldmir@mail.ru"]

  s.description = "Plugin to auto add hostgroup to host."
  s.extra_rdoc_files = ["README.md"]
  s.files = Dir["{app,lib,locale}/**/*"] + ["README.md"]
  s.homepage = "https://github.com/voldmir/foreman_default_auto_hostgroup"
  s.license = "GPL-3.0"
  s.summary = "Auto add hostgroup to host."
  s.test_files = Dir["test/**/*"]
end
