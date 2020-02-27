# frozen_string_literal: true

require 'spec_helper'

module Unused
  RSpec.describe Registry do
    before(:each) do
      Registry.instance.reset
    end

    after(:each) do
      Registry.instance.reset
    end

    describe '.register' do
      let(:subject) do
        registry = Registry
        registry.register(SampleClass)
        registry
      end

      let(:instance_method_calls) do
        subject.instance_method_calls
      end

      let(:class_method_calls) do
        subject.class_method_calls
      end

      context 'instance_methods' do
        it 'logs all instance methods on a given class' do
          methods = instance_method_calls.keys.map { |_, method| method }
          expect(methods).to match_array(
            %i[
              instance_method protected_method private_method
            ]
          )
        end
      end

      context 'classes' do
        it 'logs class methods' do
          entries = class_method_calls.keys.select do |object_id, _method|
            object_id == SampleClass.singleton_class.object_id
          end
          methods = entries.map { |_, method| method }
          expect(methods).to match_array(
            %i[
              class_method custom_private_class_method
            ]
          )
        end
      end

      context 'modules' do
        let(:subject) do
          registry = Registry
          registry.register(SampleClass)
          registry.register(SampleModule)
          registry.register(ExtendModule)
          registry
        end

        it 'assigns module methods to module' do
          included_methods = instance_method_calls.keys.select do |_, method|
            %i[module_method extend_module_method].include? method
          end
          expect(included_methods.map(&:first).uniq)
            .to match_array [SampleModule.object_id, ExtendModule.object_id]

          extended_methods = class_method_calls.keys.select do |_, method|
            %i[module_self_method extend_module_self_method].include? method
          end
          expect(extended_methods.map(&:first).uniq)
            .to match_array([
                              SampleModule.singleton_class.object_id,
                              ExtendModule.singleton_class.object_id
                            ])
        end
      end

      context 're-registering' do
        it 'does not overwrite existing entires' do
          key = [SampleClass.object_id, :instance_method]
          # log method call to increment by 1
          subject.log_instance_method(SampleClass.object_id, :instance_method)

          # re-register
          subject.register(SampleClass)
          new_class_method_calls = subject.instance_method_calls
          expect(new_class_method_calls[key]).to eq 1
        end

        it 'adds new methods' do
          class RegistryTestRedefinitionClass
            create_alias_methods(self)
            def method1; end
          end
          Registry.register(RegistryTestRedefinitionClass)

          change_and_register = proc do
            # define new instance method
            RegistryTestRedefinitionClass.define_method(:new_method) {}
            Registry.register(RegistryTestRedefinitionClass)
          end

          expect(change_and_register)
            .to(change { Registry.instance_method_calls })

          class_id = RegistryTestRedefinitionClass.object_id
          expect(Registry.instance_method_calls.keys)
            .to match_array [[class_id, :new_method], [class_id, :method1]]
        end
      end
    end

    describe '.tracked_objects' do
      it 'returns object_id for all registered objects' do
        classes = [SampleClass, SampleModule, ExtendModule]
        object_ids = classes.flat_map do |object|
          Registry.register(object)
          [object.object_id, object.singleton_class.object_id]
        end

        expect(Registry.tracked_objects).to match_array(object_ids)
      end
    end

    describe 'log_instance_method' do
      let(:subject) do
        registry = Registry
        registry.register(SampleClass)
        registry
      end

      it 'increments call counter' do
        key = [SampleClass.object_id, :instance_method]
        expect { subject.log_instance_method(SampleClass.object_id, :instance_method) }
          .to change { subject.instance_method_calls[key] }.from(0).to(1)
      end

      it 'skips if method-object key is not found' do
        log_nonexiting_method = proc do
          subject.log_instance_method(SampleClass.object_id, :not_exists)
        end
        expect(log_nonexiting_method)
          .not_to(change { subject.instance_method_calls })
      end
    end

    describe 'log_class_method' do
      let(:subject) do
        registry = Registry
        registry.register(SampleClass)
        registry
      end

      it 'increments call counter' do
        key = [SampleClass.singleton_class.object_id, :class_method]
        expect { subject.log_class_method(*key) }
          .to change { subject.class_method_calls[key] }.from(0).to(1)
      end

      it 'skips if method-object key is not found' do
        expect { subject.log_class_method(SampleClass.object_id, :not_exists) }
          .not_to(change { subject.class_method_calls })
      end
    end
  end
end
