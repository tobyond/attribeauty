# frozen_string_literal: true

module Attribeauty
  class Params
    extend Forwardable

    def_delegators :to_h, :each_pair, :each, :empty?, :keys

    def self.with(request_params)
      new(request_params)
    end

    attr_reader :allow_nil, :prefix, :request_params, :acceptables, :to_h, :errors, :strict

    def initialize(request_params)
      @request_params = request_params.transform_keys(&:to_sym)
      @to_h = {}
      @errors = []
    end

    def accept(&)
      instance_eval(&)

      raise MissingAttributeError, errors.join(", ") if errors.any? && strict?

      self
    end

    def accept!(&)
      @strict = true

      accept(&)
    end

    def to_hash = to_h

    def [](key)
      to_h[key]
    end

    def container(name)
      @request_params = request_params[name]

      yield
    end

    def attribute(name, type = nil, **args, &block)
      value = request_params[name]
      return if value.nil? && args[:required].nil?

      if block_given?
        @to_h[name.to_sym] = vals_from_nested(value, &block)
      else
        validator = Validator.run(name, value, type, **args)
        @errors.push(*validator.errors)
        @to_h[name.to_sym] = validator.value if validator.valid?
      end
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

    def vals_from_nested(value, &block)
      if value.is_a?(Array)
        value.map do |val|
          params = self.class.with(val).accept(&block)
          @errors.push(*params.errors)
          params.to_h
        end.reject(&:empty?)
      else
        params = self.class.with(value).accept(&block)
        @errors.push(*params.errors)
        params.to_h
      end
    end
  end
end
