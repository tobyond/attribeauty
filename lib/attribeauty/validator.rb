# frozen_string_literal: true

require "forwardable"

module Attribeauty
  class Validator
    ALLOWS_HASH = {
      allow_nil: :nil?,
      allow_empty: :empty?
    }.freeze

    def self.run(name, type, original_value, **args)
      new(name, type, original_value, **args).run
    end

    attr_reader :original_value, :errors, :name, :type, :required, :default, :predicate, :value

    def initialize(name, type, original_value, **args)
      @name = name
      @type = type
      @original_value = original_value
      @errors = []
      @default = args[:default]
      @required = args[:required] if [true, false].include?(args[:required])
      allows = args.slice(*allows_array)
      return if allows.empty?

      predicate_array = allows.first
      predicate_array[0] = :"#{ALLOWS_HASH[predicate_array[0]]}"
      @predicate = predicate_array
    end

    def run
      @original_value = default if original_value.nil? && !default.nil?
      @value = TypeCaster.run(original_value, type)

      self
    end

    def valid?
      if required? && original_value.nil?
        errors << "#{name} required"
        return false
      end
      return true if predicate.nil?

      method, bool = predicate
      return true if bool

      !value.public_send(method)
    end

    private

    def set_args; end

    def allows_array
      ALLOWS_HASH.keys
    end

    def required?
      required
    end
  end
end
