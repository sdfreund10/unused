# frozen_string_literal: true

require 'singleton'
require_relative './registry'

module Unused
  class CallListener
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
      TracePoint.new(:call) do |tp|
        tracked_objects = Registry.tracked_objects
        method = tp.method_id
        owner = tp.self.method(method).owner
        next unless tracked_objects.include? owner.object_id

        if owner.singleton_class?
          Registry.log_class_method(owner.object_id, method)
        else
          Registry.log_instance_method(owner.object_id, method)
        end
      end
    end
  end
end
