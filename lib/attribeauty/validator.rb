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
      args.delete_if { |key, value| key == :required && value == false }
      @required = args[:required]
      @excludes = args[:exclude_if]

      @valid = true
      @errors = []
    end

    def run
      handle_missing_original_val!
      handle_missing_required!
      handle_missing_type

      set_default
      cast_value
      handle_excludes

      self
    rescue ValueInvalidError
      self
    end

    def valid?
      valid
    end

    def required?
      required
    end

    private

    def handle_missing_original_val!
      return unless !required? && original_val.nil?

      @valid = false 
      raise ValueInvalidError
    end

    # only returning errors if required is missing, not if nil?, or :empty?
    def handle_missing_required!
      return unless required? && original_val.nil?

      errors << "#{name} required"
      @valid = false
      raise ValueInvalidError
    end

    def handle_missing_type
      @value = original_val if type.nil?
    end

    def set_default
      return unless original_val.nil? && !default.nil?

      @original_val = default
    end

    def cast_value
      @value ||= TypeCaster.run(original_val, type)
    end

    def handle_excludes
      return if excludes.nil? || !valid?

      @valid = ![*excludes].flatten.any? { |exclude| value.public_send(exclude) }
    end
  end
end
