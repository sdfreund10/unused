# frozen_string_literal: true

require 'singleton'
require_relative './registry'

module Unused
  class DefinitionListener
    include Singleton

    def initialize
      @trace = define_tracepoint
    end

    def enable
      @trace.enable
    end

    def disable
      @trace.disable
    end

    private

    def define_tracepoint
      TracePoint.new(:end) do |tp|
        next unless tp.path.start_with?(Unused.config.path)

        Registry.register(tp.self)
      end
    end
  end
end
