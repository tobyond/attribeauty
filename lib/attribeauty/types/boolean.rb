# frozen_string_literal: true

module Attribeauty
  module Types
    # custom boolean type
    class Boolean
      FALSE_VALUES = [
        false, 0,
        "0", :"0",
        "f", :f,
        "F", :F,
        "false", :false,
        "FALSE", :FALSE,
        "off", :off,
        "OFF", :OFF
      ].to_set.freeze

      def cast(value)
        !FALSE_VALUES.include?(value)
      end
    end
  end
end
