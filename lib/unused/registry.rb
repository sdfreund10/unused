# frozen_string_literal: true

require 'singleton'
require_relative './reporter'

module Unused
  class Registry
    include Singleton

    def self.register(defined_class)
      instance.register(defined_class)
    end

    def self.log_instance_method(callee_id, method_id)
      instance.log_instance_method(callee_id, method_id)
    end

    def self.log_class_method(callee_id, method_id)
      instance.log_class_method(callee_id, method_id)
    end

    def self.report
      instance.report
    end

    def self.tracked_objects
      instance.tracked_objects
    end

    def initialize
      @class_method_calls = {}
      @instance_method_calls = {}
      @class_id_map = {}
    end

    def tracked_objects
      @class_id_map.keys
    end

    def register(defined_class)
      id = defined_class.object_id
      @class_id_map[id] = defined_class.to_s

      defined_class.instance_methods(false).each do |method|
        key = [id, method]
        next if @instance_method_calls.key?(key)

        @instance_method_calls.store(key, 0)
      end

      register_class_methods(defined_class)
    end

    def log_class_method(callee_id, method)
      hash_key = [callee_id, method]

      # metaprogramming can sometime define methods not in the registry
      # skip in this case
      return unless @class_method_calls.key?(hash_key)

      incrment_class_method_call(hash_key)
    end

    def log_instance_method(callee_class_id, method)
      hash_key = [callee_class_id, method]

      # metaprogramming can sometime define methods not in the registry
      # skip in this case
      return unless @instance_method_calls.key?(hash_key)

      increment_instance_method_call(hash_key)
    end

    def report
      print(@instance_method_calls, "\n")
      print(@class_method_calls, "\n")
    end

    private

    def register_class_methods(defined_class)
      # Class methods are owned by a defined class's "singleton"
      # Singleton classes are only created on class method definition
      # or when calling Class#singleton_class
      # Thus, to prevent a needless allocation, check if there is
      # any need to register the singleton
      class_methods = defined_class.methods(false)
      return if class_methods.empty?

      singleton_id = defined_class.singleton_class.object_id
      @class_id_map[singleton_id] = defined_class.to_s
      class_methods.each do |method|
        key = [singleton_id, method]
        next if @class_method_calls.key?(key)

        @class_method_calls.store(key, 0)
      end
    end

    def increment_instance_method_call(hash_key)
      @instance_method_calls[hash_key] += 1
    end

    def incrment_class_method_call(hash_key)
      @class_method_calls[hash_key] += 1
    end
  end
end
