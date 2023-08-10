# frozen_string_literal: true

require_relative "attribeauty/version"
require_relative "attribeauty/base"
require_relative "attribeauty/type_caster"
require_relative "attribeauty/configuration"
require "date"
require "time"

# Module
module Attribeauty
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
