# frozen_string_literal: true

def create_alias_methods(obj)
  Unused::MethodAliasListener.instance.send(
    :alias_essential_methods,
    obj
  )
end
