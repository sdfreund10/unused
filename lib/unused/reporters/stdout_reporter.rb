# frozen_string_literal: true

require_relative 'method'
require_relative 'base'

module Unused
  module Reporters
    class StdoutReporter < Base
      HEADERS = %w[
        Method
        Calls
        Source
      ].freeze

      def initialize(instance_methods, class_methods, map)
        @instance_methods = instance_methods
        @class_methods = class_methods
        @map = map
      end

      def report
        print(output)
      end

      def output
        method_length, call_length, loc_length = column_lengths
        data = output_data
        output = ''
        output += HEADERS[0].ljust(method_length, ' ') + "\t"
        output += HEADERS[1].ljust(call_length, ' ') + "\t"
        output += HEADERS[2].ljust(loc_length, ' ') + "\t"
        output += "\n"

        data.each do |method, calls, location|
          output += method.ljust(method_length, ' ') + "\t"
          output += calls.rjust(call_length, ' ') + "\t"
          output += location.ljust(loc_length, ' ') + "\t"
          output += "\n"
        end

        output
      end

      private

      def output_data
        unused_methods.map do |method|
          [method.representation,
           method.calls.to_s,
           method.source]
        end
      end

      def column_lengths
        output_data.transpose.map.with_index do |values, index|
          [
            HEADERS[index].length,
            values.map(&:length).max
          ].max
        end
      end

      def unused_methods
        method_summary.select do |method|
          method.calls.zero?
        end
      end
    end
  end
end
