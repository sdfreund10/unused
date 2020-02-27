# frozen_string_literal: true

require 'spec_helper'

module Unused
  RSpec.describe DefinitionListener do
    before(:each) do
      # RSpec.configure { |config| config.warnings = false }
      Registry.instance.reset
      DefinitionListener.instance.enable
    end
    after(:each) do
      DefinitionListener.instance.disable
      Registry.instance.reset
      # RSpec.configure { |config| config.warnings = true }
    end

    it 'adds class and methods to registry' do
      class DefinitionListenerTestClass1
        create_alias_methods(self)
        def instance_method; end

        def self.class_method; end
      end
      expect(Registry.tracked_objects).to match_array [
        DefinitionListenerTestClass1.object_id,
        DefinitionListenerTestClass1.singleton_class.object_id
      ]

      expect(Registry.instance_method_calls).to include(
        [DefinitionListenerTestClass1.object_id, :instance_method] => 0
      )
      expect(Registry.class_method_calls).to include(
        [
          DefinitionListenerTestClass1.singleton_class.object_id,
          :class_method
        ] => 0
      )
    end

    it 'adds methods on re-defined classes' do
      class DefinitionListenerTestClass2
        create_alias_methods(self)
        def method; end
      end
      class_id = DefinitionListenerTestClass2.object_id
      expect(Registry.tracked_objects).to include(class_id)
      expect(Registry.instance_method_calls.keys).to eq [
        [class_id, :method]
      ]
      class DefinitionListenerTestClass2
        def new_method; end
      end
      expect(Registry.instance_method_calls.keys).to eq [
        [class_id, :method],
        [class_id, :new_method]
      ]
    end

    it 'registers meta-programed methods from parent' do
      class DefinitionListenerParentClass1
        create_alias_methods(self)
        def self.make_method(method_name)
          define_method(method_name) {}
        end
      end

      class DefinitionListenerChildClass1 < DefinitionListenerParentClass1
        make_method(:meta_programmed_method)
      end

      class_id = DefinitionListenerChildClass1.object_id

      expect(Registry.instance_method_calls.keys).to match_array [
        [class_id, :meta_programmed_method]
      ]
    end

    it 'does not register inherited methods' do
      class DefinitionListenerParentClass2
        create_alias_methods(self)
        def self.parent_method; end
      end

      class DefinitionListenerChildClass2 < DefinitionListenerParentClass2
      end

      child_id = DefinitionListenerChildClass2.singleton_class.object_id

      expect(Registry.class_method_calls.keys).not_to include(
        [child_id, :parent_method]
      )
    end

    it 'registers methods defined at runtime' do
      skip 'not currently supported'
      # The definition listener hook is only triggered on traditional
      # class definition, ie class SomeClass; ...; end
      # Supporting runtime methods might require patching Object, which is
      # probably not worth it

      class DefinitionalListenerRuntimeMethodTestClass
        create_alias_methods(self)
      end

      DefinitionalListenerRuntimeMethodTestClass
        .define_method(:runtime_method) {}

      expect(Registry.instance_method_calls.keys).to eq(
        [
          [
            DefinitionalListenerRuntimeMethodTestClass.object_id,
            :runtime_method
          ]
        ]
      )
    end
  end
end
