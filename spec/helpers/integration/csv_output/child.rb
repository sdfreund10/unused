# frozen_string_literal: true

module Unused
  module Integration
    module CsvOutput
      class Child < Parent
        # override parent method
        def base_method; end

        def unused_method; end
      end
    end
  end
end
