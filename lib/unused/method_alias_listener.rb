# frozen_string_literal: true

require 'singleton'

module Unused
  class MethodAliasListener
    include Singleton

    ESSENTIAL_METHODS = %w[
      object_id
      methods
      private_methods
      singleton_class
      method
    ].freeze

    ESSENTIAL_METHODS_TO_DEFINE = %w[
      instance_methods
      private_instance_methods
      instance_method
    ].freeze

    def initialize
      @trace = define_tracepoint
    end

    def enable
      @trace.enable
    end

    def disable
      @trace.disable
    end

    def self.alias_pattern(method_name)
      "_#{method_name}_UNUSED_ALIAS_"
    end

    private

    def define_tracepoint
      TracePoint.new(:class) do |tp|
        if tp.path.start_with?(Unused.config.path)
          alias_essential_methods(tp.self)
        end
      end
    end

    def alias_essential_methods(defined_obj)
      ESSENTIAL_METHODS.each do |method|
        alias_name = self.class.alias_pattern(method)
        defined_obj.alias_method(alias_name, method)
        defined_obj.singleton_class.alias_method(alias_name, method)
      end

      ESSENTIAL_METHODS_TO_DEFINE.each do |method|
        alias_name = self.class.alias_pattern(method)
        defined_obj.define_method(method) { |*args| super(*args) }
        defined_obj.singleton_class.define_method(method) { |*args| super(*args) }
        defined_obj.alias_method(alias_name, method)
        defined_obj.singleton_class.alias_method(alias_name, method)
        defined_obj.remove_method(method)
        defined_obj.singleton_class.remove_method(method)
      end
    end
  end
end
