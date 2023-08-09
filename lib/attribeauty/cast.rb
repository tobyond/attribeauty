# frozen_string_literal: true

require_relative "types/string"
require_relative "types/integer"
require_relative "types/float"
require_relative "types/boolean"
require_relative "types/time"

module Attribeauty
  # base cast for types
  class Cast
    BASE_TYPES = {
      float: Types::Float,
      integer: Types::Integer,
      boolean: Types::Boolean,
      time: Types::Time,
      string: Types::String
    }.freeze

    def self.cast(value, type)
      return nil if value.nil?

      all_types = Attribeauty.configuration.types

      raise ArgumentError, "#{type} not supported" if all_types[type].nil?

      all_types[type].new.cast(value)
    end
  end
end
