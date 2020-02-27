# frozen_string_literal: true

module Unused
  module Reporters
    class Base
      private

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
end
