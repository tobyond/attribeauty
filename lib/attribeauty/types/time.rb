# frozen_string_literal: true

module Attribeauty
  module Types
    # custom Time type
    class Time
      def cast(value)
        return if value.nil?

        case value
        when Time
          value
        when Date, DateTime
          value.to_time
        when Integer
          ::Time.at(value / 1000.0)
        when Numeric
          ::Time.at(value)
        else
          ::Time.parse(value)
        end
      end
    end
  end
end
