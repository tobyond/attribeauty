# frozen_string_literal: true

module Attribeauty
  # base cast for types
  class TypeCaster
    BASE_TYPES = {
      float: Types::Float,
      integer: Types::Integer,
      boolean: Types::Boolean,
      time: Types::Time,
      string: Types::String
    }.freeze

    def self.run(value, type)
      return nil if value.nil?

      all_types = Attribeauty.configuration.types

      raise ArgumentError, "#{type} not supported" if all_types[type].nil?

      all_types[type].new.cast(value)
    end
  end
end
