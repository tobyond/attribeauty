# frozen_string_literal: true

module Attribeauty
  # Attribeauty.configure do |config|
  #   config.types[:koala] = MyClass::Koala
  # end
  class Configuration
    attr_accessor :types

    def initialize
      @types = TypeCaster::BASE_TYPES.dup
    end
  end
end
