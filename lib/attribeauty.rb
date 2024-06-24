# frozen_string_literal: true

require "date"
require "time"
require "forwardable"

# Module
module Attribeauty
  class Error < StandardError; end
  class MissingAttributeError < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/kamal/sshkit_with_ext.rb")
loader.setup
loader.eager_load # We need all commands loaded.
