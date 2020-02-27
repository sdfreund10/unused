# frozen_string_literal: true

require 'spec_helper'

module Unused
  module Reporters
    RSpec.describe CSVReporter do
      let(:output_file) do
        File.expand_path(__dir__) + '/./csv_spec_output.csv'
      end

      before do
        Unused.config.output_file = output_file
      end

      after do
        FileUtils.rm(output_file)
      end

      let(:instance_calls) do
        object_id = SampleClass.object_id
        {
          [object_id, :instance_method] => 1,
          [object_id, :private_method] => 0
        }
      end

      let(:class_calls) do
        object_id = SampleClass.singleton_class.object_id
        {
          [object_id, :class_method] => 1
        }
      end

      let(:class_id_map) do
        {
          SampleClass.object_id => SampleClass,
          SampleClass.singleton_class.object_id => SampleClass
        }
      end

      let(:subject) do
        CSVReporter.new(instance_calls, class_calls, class_id_map)
      end

      it 'outputs results to csv file' do
        subject.report
        output = File.readlines(output_file)
        # output for 3 methods + the header row
        expect(output.size).to eq(4)
        expect(output.first.strip.split(',')).to eq(CSVReporter::HEADERS)
        # have the method with 0 calls first
        expect(output[1]).to include('private_method')
      end
    end
  end
end
