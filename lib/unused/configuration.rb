# frozen_string_literal: true

require 'singleton'

module Unused
  class Configuration
    include Singleton

    attr_accessor :path, :output_file

    def initialize
      @path = Dir.pwd
      @output_file = "#{Dir.pwd}/unused_methods.csv"
    end
  end
end
