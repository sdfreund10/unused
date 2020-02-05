# frozen_string_literal: true

require_relative 'unused/registry'
require_relative 'unused/reporter'
require_relative 'unused/definition_listener'
require_relative 'unused/call_listener'

module Unused
  def self.start
    DefinitionListener.instance.enable
    CallListener.instance.enable
    at_exit do
      Registry.report
    end
  end
end
