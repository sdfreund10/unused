# frozen_string_literal: true

require_relative 'unused/registry'
require_relative 'unused/reporter'
require_relative 'unused/definition_listener'
require_relative 'unused/call_listener'
require_relative 'unused/configuration'

module Unused
  def self.start
    DefinitionListener.instance.enable
    CallListener.instance.enable
    at_exit { report } if config.report_at_exit
  end

  def self.stop
    DefinitionListener.instance.disable
    CallListener.instance.disable
  end

  def self.config
    Configuration.instance
  end

  def self.configure
    yield config
  end

  def self.report
    Reporter.call
  end
end
