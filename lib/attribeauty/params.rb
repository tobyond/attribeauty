# frozen_string_literal: true

module Attribeauty
  class Params
    extend Forwardable

    def_delegators :to_h, :each_pair, :each, :empty?, :keys

    def self.with(request_params)
      new(request_params)
    end

    attr_reader :prefix, :request_params, :acceptables, :to_h, :errors, :strict, :default_args

    def initialize(request_params)
      @request_params = (request_params || {}).transform_keys(&:to_sym)
      @to_h = {}
      @errors = []
    end

    def accept(**args, &)
      @default_args = args
      instance_eval(&)

      raise MissingAttributeError, errors.join(", ") if errors.any? && strict?

      self
    end

    def accept!(**args, &)
      @strict = true

      accept(**args, &)
    end

    def to_hash = to_h

    def [](key)
      to_h[key]
    end

    def []=(key, value)
      to_h[key] = value
    end

    def root(name)
      @request_params = request_params[name]

      yield
    end

    def attribute(name, type = nil, **args, &block)
      value = request_params[name]
      return hash_from_nested(name, value, &block) if block_given?

      value_from_validator(name, value, type, **args)
    end

    def inspect
      to_h.inspect
    end

    def valid?
      errors.empty?
    end

    def strict?
      strict
    end

    private

    def value_from_validator(name, value, type, **args)
      merged_args = args.merge(default_args || {})
      validator = Validator.run(name, value, type, **merged_args)
      @errors.push(*validator.errors)
      @to_h[name.to_sym] = validator.value if validator.valid?
    end

    def hash_from_nested(name, value, &block)
      result =
        if value.is_a?(Array)
          value.map do |val|
            params = self.class.with(val).accept(**default_args, &block)
            @errors.push(*params.errors)
            params.to_h
          end.reject(&:empty?)
        else
          params = self.class.with(value).accept(**default_args, &block)
          @errors.push(*params.errors)
          params.to_h
        end

      @to_h[name.to_sym] = result unless result.empty?
    end
  end
end
