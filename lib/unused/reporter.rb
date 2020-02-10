# frozen_string_literal: true

module Unused
  class Reporter
    def initialize(calls, id_map, singleton_map)
      @calls = calls
      @id_map = id_map
      @singleton_map = singleton_map
    end

    def zero_call_class_methods
      zero_call_methods = []
      @singleton_map.each do |singleton_id, base_class|
        @calls[singleton_id].each do |method, calls|
          next unless calls.zero?

          zero_call_methods << [base_class, method]
        end
      end

      zero_call_methods
    end

    def zero_call_instance_methods
      zero_call_methods = []
      @id_map.each do |class_id, class_name|
        @calls[class_id].each do |method, calls|
          next unless calls.zero?

          zero_call_methods << [class_name, method]
        end
      end

      zero_call_methods
    end

    def call
      class_methods = zero_call_class_methods
      instance_methods = zero_call_instance_methods
      unless zero_call_instance_methods.empty? && zero_call_class_methods.empty?
        puts 'The following methods may not be used:'
        zero_call_class_methods.each do |klass, method|
          puts "#{klass}.#{method}"
        end

        instance_methods.each do |klass, method|
          puts "#{klass}\##{method}"
        end
      end
    end
  end
end
