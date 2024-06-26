# frozen_string_literal: true

module Attribeauty
  # base class to inherit from
  # class MyClass < Attribeauty::Base
  class Base
    def self.attribute(name, type, **args)
      @attributes ||= {}
      return if @attributes[name]

      @attributes[name] = type

      class_eval(<<-CODE, __FILE__, __LINE__ + 1)
        def #{name}=(value)
          validator = Validator.run(#{name.inspect}, value, #{type.inspect}, #{args})
          raise MissingAttributeError, validator.errors.join(', ') if validator.errors.any?
          @#{name} = validator.value
        end

        def #{name};@#{name};end
      CODE

      return unless type == :boolean

      class_eval(<<-CODE, __FILE__, __LINE__ + 1)
        def #{name}?; !!#{name}; end
      CODE
    end

    def initialize(**attributes)
      attributes.each do |key, value|
        method = "#{key}=".to_sym
        public_send(method, value)
      end
    end

    def assign_attributes(**attributes)
      attributes.each do |key, value|
        method = "#{key}=".to_sym
        public_send(method, value)
      end
    end
  end
end
