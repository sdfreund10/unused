# frozen_string_literal: true

require 'spec_helper'

module Unused
  RSpec.describe CallListener do
    before(:each) do
      Registry.instance.reset
      CallListener.instance.enable
    end

    after(:each) do
      CallListener.instance.disable
      Registry.instance.reset
    end

    it 'increments instance method calls' do
      Registry.register(SampleClass)
      expect { SampleClass.new.instance_method }
        .to(change { Registry.instance_method_calls })

      expect(
        Registry.instance_method_calls[
          [SampleClass.object_id, :instance_method]
        ]
      ).to eq 1
    end

    it 'incremenets class method calls' do
      Registry.register(SampleClass)
      expect { SampleClass.class_method }
        .to(change { Registry.class_method_calls })

      key = [SampleClass.singleton_class.object_id, :class_method]
      expect(
        Registry.class_method_calls[key]
      ).to eq 1
    end

    it 'increments module method calls' do
      Registry.register(SampleClass)
      Registry.register(SampleModule)
      expect { SampleClass.new.module_method }
        .to(change { Registry.instance_method_calls })

      key = [SampleModule.object_id, :module_method]
      expect(
        Registry.instance_method_calls[key]
      ).to eq 1
    end

    it 'increments inherited method calls' do
      class ChildSampleClass < SampleClass; end

      Registry.register(SampleClass)
      Registry.register(ChildSampleClass)
      expect { ChildSampleClass.new.instance_method }
        .to(change { Registry.instance_method_calls })

      key = [SampleClass.object_id, :instance_method]
      expect(Registry.instance_method_calls[key])
        .to eq 1
    end

    it 'increments calls from send' do
      Registry.register(SampleClass)
      SampleClass.new.send(:protected_method)
      SampleClass.new.send(:private_method)
      key = [SampleClass.object_id, :private_method]
      expect(Registry.instance_method_calls[key])
        .to eq 1
    end
  end
end
