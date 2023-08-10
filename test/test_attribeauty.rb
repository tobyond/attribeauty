# frozen_string_literal: true

require "test_helper"

class TestAttribeauty < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Attribeauty::VERSION
  end

  def test_it_handles_string
    assert MyClass.new(first: 1234).first, "1234"
  end

  def test_it_handles_integer
    assert MyClass.new(second: "1234").second, 1234
  end

  def test_it_handles_float
    assert MyClass.new(third: "12.34").third, 12.34
  end

  def test_it_handles_boolean_true_as_string
    assert MyClass.new(forth: "TRUE").forth, true
  end

  def test_it_handles_boolean_true_as_true
    assert MyClass.new(forth: true).forth, true
  end

  def test_it_handles_boolean_false_as_string
    assert !MyClass.new(forth: "FALSE").forth, true
  end

  def test_it_handles_boolean_false_as_false
    assert !MyClass.new(forth: false).forth, true
  end

  def test_it_handles_boolean_predicate
    assert MyClass.new(forth: "TRUE").forth?, true
  end

  def test_it_handles_time
    assert MyClass.new(fifth: "2014-12-25 14:00:00 +0100").fifth,
           Time.new(2014, 12, 25, 13, 0o0, 0o0, 0)
  end

  def test_configuration_types
    assert Attribeauty::Configuration.new.types, Attribeauty::TypeCaster::BASE_TYPES
  end

  def test_configuration_adding
    Attribeauty.configure do |config|
      config.types[:koala] = MyClass::Koala
    end
    new_types = Attribeauty::TypeCaster::BASE_TYPES.merge(koala: MyClass::Koala)

    assert Attribeauty.configuration, new_types
  end

  def test_custom_type
    Attribeauty.configure do |config|
      config.types[:koala] = MyClass::Koala
    end

    assert MyClass.new(sixth: "i_watch_out_for").sixth, "i_watch_out_for_koalas"
  end

  def test_assign_attributes
    instance = MyClass.new(first: :first)

    instance.assign_attributes(second: "1234", third: 12.34)
    instance.assign_attributes(second: "1235", forth: "TRUE")

    assert instance.first, "first"
    assert instance.second, 1235
    assert instance.third, 12.34
    assert instance.forth, true
  end

  def test_manual_assign
    instance = MyClass.new(first: :first)

    assert instance.first, "first"

    instance.first = 7890

    assert instance.first, "7890"
  end
end

class MyClass < Attribeauty::Base
  attribute :first, :string
  attribute :second, :integer
  attribute :third, :float
  attribute :forth, :boolean
  attribute :fifth, :time
  attribute :sixth, :koala

  class Koala
    def cast(value)
      value.inspect.to_s << "_koalas"
    end
  end
end
