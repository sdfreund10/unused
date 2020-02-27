# frozen_string_literal: true

require_relative './sample_module'
require_relative './extend_module'
require_relative './helpers'

class SampleClass
  create_alias_methods(self)
  include SampleModule
  extend ExtendModule

  def instance_method; end

  def self.class_method; end

  protected

  def protected_method; end

  private

  def private_method; end

  def self.custom_private_class_method; end
  private_class_method :custom_private_class_method
end
