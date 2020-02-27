# frozen_string_literal: true

require_relative 'reporters/csv_reporter'
require_relative 'reporters/stdout_reporter'

module Unused
  class Reporter
    def self.call
      reporter_class.new(
        Registry.instance_method_calls,
        Registry.class_method_calls,
        Registry.class_map
      ).report
    end

    def self.reporter_class
      case Unused.config.reporter
      when :csv
        Reporters::CSVReporter
      else
        Reporters::StdoutReporter
      end
    end
  end
end
