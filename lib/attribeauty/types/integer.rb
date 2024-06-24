# frozen_string_literal: true

module Attribeauty
  module Types
    # custom integer type
    class Integer
      def cast(value)
        return if value.nil?

        Integer(value)
      end
    end
  end
end
