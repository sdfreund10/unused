# frozen_string_literal: true

require 'spec_helper'

module Unused
  RSpec.describe Method do
    let(:truncated_file_path) do
      __FILE__.sub(Unused.config.path, '')
    end

    context 'instance method' do
      before(:all) do
        class MethodSpecInstanceMethodSample
          def method1; end
        end
      end

      let(:subject) do
        Method.new(
          :method1,
          MethodSpecInstanceMethodSample,
          'instance',
          0
        )
      end

      describe '#representation' do
        it "returns 'Owner#method'" do
          expect(subject.representation)
            .to eq 'Unused::MethodSpecInstanceMethodSample#method1'
        end
      end

      describe '#source' do
        it 'returns file_path:line' do
          # could change if this file changes
          line_number = File.readlines(__FILE__).find_index do |text|
            text.include? 'def method1'
          end

          expect(subject.source)
            .to eq("#{truncated_file_path}:#{line_number + 1}")
        end
      end
    end

    context 'class method' do
      before(:all) do
        class MethodSpecClassMethodSample
          def self.method1; end
        end
      end

      let(:subject) do
        Method.new(
          :method1,
          MethodSpecClassMethodSample,
          'class',
          0
        )
      end

      describe '#representation' do
        it "returns 'Owner::method'" do
          expect(subject.representation)
            .to eq 'Unused::MethodSpecClassMethodSample::method1'
        end
      end

      describe '#source' do
        it 'returns file_path:line' do
          # could change if this file changes
          line_number = File.readlines(__FILE__).find_index do |text|
            text.include? 'def self.method1'
          end

          expect(subject.source)
            .to eq("#{truncated_file_path}:#{line_number + 1}")
        end
      end
    end
  end
end
