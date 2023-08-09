# frozen_string_literal: true

module Attribeauty
  module Types
    # custom string type
    class String
      def cast(value)
        String(value)
      end
    end
  end
end
