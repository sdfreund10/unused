# frozen_string_literal: true

# test all types of file loading
require File.expand_path("#{__dir__}/extended_module")
load File.expand_path("#{__dir__}/included_module.rb")

module Unused
  module Integration
    module CsvOutput
      class Parent
        include IncludedModule
        extend ExtendedModule

        def base_method
          private_method
        end

        def self.base_class_method; end

        private

        def private_method; end
      end
    end
  end
end
