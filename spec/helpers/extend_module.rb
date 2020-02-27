# frozen_string_literal: true

require_relative './helpers'

module ExtendModule
  create_alias_methods(self)
  def extend_module_method; end

  def self.extend_module_self_method; end
end
