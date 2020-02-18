# frozen_string_literal: true

require_relative 'reporters/csv_reporter'

module Unused
  class Reporter
    def self.call
      CSVReporter.new(
        Registry.instance_method_calls,
        Registry.class_method_calls,
        Registry.class_map
      ).report
    end
  end
end
