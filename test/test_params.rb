# frozen_string_literal: true

require "test_helper"

class TestParams < Minitest::Test
  def params_object(params = {})
    Attribeauty::Params.with(params)
  end

  def test_when_already_valid
    params = { title: "woo", email: { address: "hmm@yep.com" } }
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :title, :string, allow_nil: false, required: true
      attribute :email do
        attribute :address, :string, allow_empty: false
        attribute :valid, :boolean, allow_nil: false
        attribute :ip_address, :string, allow_blank: true
      end
    end

    assert_equal result.to_h.to_s, params.to_s
  end

  def test_when_empty_string
    params = { title: "woo", email: { address: "", ip_address: "192.168.0.1" } }
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :title, :string, allow_nil: false, required: true
      attribute :email do
        attribute :address, :string, allow_empty: false
        attribute :valid, :boolean, allow_nil: false
        attribute :ip_address, :string, allow_blank: true
      end
    end
    expected_result = { title: "woo", email: { ip_address: "192.168.0.1" } }.to_s

    assert_equal result.to_h.to_s, expected_result
  end

  def test_when_array_is_passed
    params = {
      title: "woo",
      email: [
        { address: "hmm@yep.com" },
        { address: "yo@man.com" },
        { address: "" }
      ]
    }
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :title, :string, allow_nil: false, required: true
      attribute :email do
        attribute :address, :string, allow_empty: false
        attribute :valid, :boolean, allow_nil: false
        attribute :ip_address, :string, allow_blank: true
      end
    end
    expected_result = {
      title: "woo",
      email: [{ address: "hmm@yep.com" }, { address: "yo@man.com" }]
    }.to_s

    assert_equal result.to_h.to_s, expected_result
  end

  def test_deeply_nested
    params = {
      title: "woo",
      profile: [
        { email: "hmm@yep.com" },
        { address: { street_name: "Main St" } }
      ]
    }
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :title, :string, allow_nil: false, required: true
      attribute :profile do
        attribute :email, :string, allow_nil: false
        attribute :address do
          attribute :street_name, :string, allow_nil: false
        end
      end
    end
    expected_result = {
      title: "woo",
      profile: [
        { email: "hmm@yep.com" },
        { address: { street_name: "Main St" } }
      ]
    }.to_s

    assert_equal result.to_h.to_s, expected_result
  end

  def test_when_casting
    params = { title: 1, email: { address: "hmm@yep.com", valid: "FALSE", ip_address: 100.2 } }
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :title, :string, allow_nil: false, required: true
      attribute :email do
        attribute :address, :string, allow_empty: false
        attribute :valid, :boolean, allow_nil: false
        attribute :ip_address, :string, allow_blank: true
      end
    end
    expected_result = {
      title: "1",
      email: { address: "hmm@yep.com", valid: false, ip_address: "100.2" }
    }.to_s

    assert_equal result.to_h.to_s, expected_result
  end

  def test_deeply_nested_errors_and_validity
    params = {
      profile: [
        { address: { street_name: "Main St" } }
      ]
    }
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :title, :string, allow_nil: false, required: true
      attribute :profile do
        attribute :email, :string, required: true
        attribute :address do
          attribute :street_name, :string, allow_nil: false
        end
      end
    end
    expected_result = {
      profile: [
        { address: { street_name: "Main St" } }
      ]
    }.to_s

    assert_equal result.to_h.to_s, expected_result
    assert_equal result.errors, ["title required", "email required"]
    assert_equal result.valid?, false
  end
end
