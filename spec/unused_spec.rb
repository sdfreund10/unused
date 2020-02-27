# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unused do
  context 'csv reporter' do
    let(:output_file) do
      File.expand_path(__dir__) + '/./test_unused_output.csv'
    end

    before do
      Unused.configure do |config|
        config.path = File.expand_path(__dir__, 'helpers/integration/csv_output')
        config.output_file = output_file
      end
      Unused.start
    end

    after do
      Unused.stop
      Unused.configure { |config| config.path = File.expand_path(__dir__) }
      FileUtils.rm(output_file)
    end

    it 'registers method calls and outputs results to csv file' do
      # this test's world is contained in spec/helpers/integration/csv_output
      require_relative './helpers/integration/csv_output.rb'
      # basic method call
      Unused::Integration::CsvOutput::Parent.new.base_method
      # method overwritten by child
      Unused::Integration::CsvOutput::Child.new.base_method
      # inherited
      Unused::Integration::CsvOutput::Child.base_class_method
      Unused::Integration::CsvOutput::Child.base_class_method
      # module method
      Unused::Integration::CsvOutput::Parent.new.module_method
      # extended module method
      Unused::Integration::CsvOutput::Parent.another_module_method

      Unused.report

      output = CSV.readlines(output_file, headers: true)
      methods = output.map do |row|
        row['representation']
      end
      expect(methods).to match_array(
        [
          'Unused::Integration::CsvOutput::Child#unused_method',
          'Unused::Integration::CsvOutput::Child#base_method',
          'Unused::Integration::CsvOutput::Parent#base_method',
          'Unused::Integration::CsvOutput::Parent#private_method',
          'Unused::Integration::CsvOutput::Parent::base_class_method',
          'Unused::Integration::CsvOutput::IncludedModule#module_method',
          'Unused::Integration::CsvOutput::ExtendedModule#another_module_method'
        ]
      )
      # expect output to be in order of number of calls
      expect(output.map { |row| row['calls'] })
        .to eq %w[0 1 1 1 1 1 2]
    end
  end
end
