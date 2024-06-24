# frozen_string_literal: true

module Attribeauty
  module Types
    # custom string type
    class String
      def cast(value)
        return if value.nil?

        String(value)
      end
    end
  end
end
