# frozen_string_literal: true

require_relative './helpers'

module SampleModule
  create_alias_methods(self)
  def module_method; end

  def self.module_self_method; end
end
