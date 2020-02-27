# frozen_string_literal: true

require 'spec_helper'

module Unused
  module Reporters
    RSpec.describe StdoutReporter do
      describe '#output' do
        let(:instance_calls) do
          object_id = SampleClass.object_id
          {
            [object_id, :instance_method] => 1,
            [object_id, :private_method] => 0,
            [object_id, :protected_method] => 0
          }
        end

        let(:class_calls) do
          object_id = SampleClass.singleton_class.object_id
          {
            [object_id, :class_method] => 1,
            [object_id, :custom_private_class_method] => 0
          }
        end

        let(:class_id_map) do
          {
            SampleClass.object_id => SampleClass,
            SampleClass.singleton_class.object_id => SampleClass
          }
        end

        let(:subject) do
          StdoutReporter.new(
            instance_calls, class_calls, class_id_map
          )
        end

        it 'includes all unused methods' do
          output = subject.output
          lines = output.split("\n")
          # output for 3 methods. + header
          expect(lines.length).to eq 4
        end
      end
    end
  end
end
