# frozen_string_literal: true

require 'singleton'

module Unused
  class Configuration
    include Singleton

    attr_accessor :path

    def initialize
      @path = Dir.pwd
    end
  end
end
