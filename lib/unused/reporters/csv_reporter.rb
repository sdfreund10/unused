# frozen_string_literal: true

require_relative 'method'
require_relative 'base'
require 'csv'

module Unused
  module Reporters
    class CSVReporter < Base
      HEADERS = %w[representation owner method type calls source].freeze
      def initialize(instance_methods, class_methods, map)
        @instance_methods = instance_methods
        @class_methods = class_methods
        @map = map
      end

      def report
        CSV.open(
          Unused.config.output_file,
          'w',
          headers: HEADERS,
          write_headers: true
        ) do |csv|
          ordered_methods.each do |method|
            csv << [
              method.representation,
              method.owner,
              method.id,
              method.type,
              method.calls,
              method.source
            ]
          end
        end
      end

      private

      def ordered_methods
        method_summary.sort_by!(&:calls)
      end
    end
  end
end
