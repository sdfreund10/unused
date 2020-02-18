# frozen_string_literal: true

module Unused
  class Method
    attr_reader :id, :owner, :type, :calls

    def initialize(id, owner, type, calls)
      @id = id
      @owner = owner
      @type = type
      @calls = calls
    end

    def representation
      "#{@owner}#{representation_symbol}#{@id}"
    end

    def source
      file, line = source_location
      "#{file.sub(Unused.config.path, '')}:#{line}"
    end

    private

    def representation_symbol
      @type == 'instance' ? '#' : '::'
    end

    def source_location
      if @type == 'instance'
        @owner.instance_method(@id).source_location
      else
        @owner.method(@id).source_location
      end
    end
  end
end
