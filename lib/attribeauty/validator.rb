# frozen_string_literal: true

module Attribeauty
  class Validator
    def self.run(name, type, original_val, **args)
      new(name, type, original_val, **args).run
    end

    attr_reader :original_val, :errors, :name, :type, :required, :default, :excludes, :value, :valid

    def initialize(name, original_val, type = nil, **args)
      @name = name
      @type = type
      @original_val = original_val
      @default = args[:default]
      @required = args[:required] if args[:required] == true
      @excludes = args[:exclude_if]

      @valid = true
      @errors = []
    end

    def run
      if type.nil?
        @value = original_val
      else
        set_default
        cast_value
        handle_missing_required
        handle_excludes
      end

      self
    end

    def valid?
      valid
    end

    private

    def set_default
      return unless original_val.nil? && !default.nil?

      @original_val = default
    end

    def cast_value
      @value = TypeCaster.run(original_val, type)
    end

    # only returning errors if required is missing, not if nil?, or :empty?
    def handle_missing_required
      return unless required? && original_val.nil?

      errors << "#{name} required"
      @valid = false
    end

    def handle_excludes
      return if excludes.nil? || !valid?

      @valid = ![*excludes].flatten.any? { |exclude| value.public_send(exclude) }
    end

    def required?
      required
    end
  end
end
