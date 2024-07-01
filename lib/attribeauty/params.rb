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
      @request_params = request_params[name].transform_keys(&:to_sym)

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

    # in Rails if you have a user model you can call
    # Attribeauty::Params.with(params.to_unsafe_h).generate_for(User, :username, :name, :age, :email)
    # It will grab the type, and add an exclude_if: for all with Null false
    def generate_for(model, *columns)
      raise "Method requires Rails" unless defined?(Rails)

      root_node = model.to_s.downcase.to_sym
      cols = columns.map(&:to_s)
      root root_node do
        model.columns_hash.slice(*cols).each_value do |table|
          attrs = table.name.to_sym, table.type
          attrs << { exclude_if: :nil? } if table.null == false
          attribute(*attrs)
        end
      end

      self
    end

    def generate_for!(model, *columns)
      @strict = true

      generate_for(model, *columns)
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
