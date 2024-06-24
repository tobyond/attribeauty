# frozen_string_literal: true

module Attribeauty
  class Validator
    ALLOWS_HASH = {
      allow_nil: :nil?,
      allow_empty: :empty?
    }.freeze

    def self.run(name, type, original_val, **args)
      new(name, type, original_val, **args).run
    end

    attr_reader :original_val, :errors, :name, :type, :required, :default, :allows, :value, :valid

    def initialize(name, original_val, type = nil, **args)
      @name = name
      @type = type
      @original_val = original_val
      @default = args[:default]
      @required = args[:required] if args[:required] == true
      @allows = args.slice(*allows_array).delete_if { |_key, value| value == true }

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
        handle_predicates
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

    def handle_predicates
      return if predicate.nil? || !valid?

      @valid = !value.public_send(predicate)
    end

    def allows_array
      ALLOWS_HASH.keys
    end

    # convert allow_nil -> :nil? or allow_empty -> :empty?
    # this will be used to public_send
    # NOTE: only one will be checked, if you pass both:
    # allow_nil and allow_empty, one will be ignored
    def predicate
      return if allows.empty?

      key = allows.keys.first
      ALLOWS_HASH[key]
    end

    def required?
      required
    end
  end
end
