module ForemanDefaultAutoHostgroup
  module HostManaged
    extend ActiveSupport::Concern

    def import_facts(facts, source_proxy = nil)
      super(facts, source_proxy)
    end
  end
end
