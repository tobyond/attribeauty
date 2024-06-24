# frozen_string_literal: true

module Attribeauty
  module Types
    # custom float type
    class Float
      def cast(value)
        return if value.nil?

        Float(value)
      end
    end
  end
end
