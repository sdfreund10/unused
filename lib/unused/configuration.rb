# frozen_string_literal: true

require 'singleton'

module Unused
  class Configuration
    include Singleton

    attr_accessor :path, :output_file, :report_at_exit, :reporter

    def initialize
      @path = Dir.pwd
      @reporter = :csv
      @output_file = "#{Dir.pwd}/unused_methods.csv"
      @report_at_exit = true
    end
  end
end
