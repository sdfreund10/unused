# frozen_string_literal: true

require_relative 'method'
require 'csv'

module Unused
  class CSVReporter
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

    def method_summary
      method_summary = @instance_methods.map do |(object_id, method_id), calls|
        owner = @map[object_id]
        Method.new(method_id, owner, 'instance', calls)
      end
      @class_methods.each do |(object_id, method_id), calls|
        owner = @map[object_id]
        method_summary << Method.new(method_id, owner, 'class', calls)
      end
      method_summary
    end
  end
end
