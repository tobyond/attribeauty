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
      attribute :title, :string, required: true
      attribute :email do
        attribute :address, :string
        attribute :valid, :boolean
        attribute :ip_address, :string
      end
    end

    assert_equal result.to_h.to_s, params.to_s
  end

  def test_when_already_valid_with_default_value
    params = { title: "woo", email: { address: "hmm@yep.com" } }
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :title, :string, required: true
      attribute :email do
        attribute :address, :string
        attribute :valid, :boolean, default: true
        attribute :ip_address, :string
      end
    end
    expected_result = { title: "woo", email: { address: "hmm@yep.com", valid: true } }

    assert_equal result.to_h.to_s, expected_result.to_s
  end

  def test_when_empty_string
    params = { title: "woo", email: { address: "", ip_address: "192.168.0.1" } }
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :title, :string, required: true
      attribute :email do
        attribute :address, :string, exclude_if: :empty?
        attribute :valid, :boolean
        attribute :ip_address, :string
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
        { address: "" },
        { address: nil }
      ]
    }
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :title, :string, required: true
      attribute :email do
        attribute :address, :string, exclude_if: %i[empty? nil?]
        attribute :valid, :boolean
        attribute :ip_address, :string, default: "192.168.0.1"
      end
    end
    expected_result = {
      title: "woo",
      email: [
        { address: "hmm@yep.com", ip_address: "192.168.0.1" },
        { address: "yo@man.com", ip_address: "192.168.0.1"  },
        { ip_address: "192.168.0.1" },
        { ip_address: "192.168.0.1" }
      ]
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
      attribute :title, :string, required: true
      attribute :profile do
        attribute :email, :string
        attribute :address do
          attribute :street_name, :string
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
      attribute :title, :string, required: true
      attribute :email do
        attribute :address, :string
        attribute :valid, :boolean
        attribute :ip_address, :string
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
      attribute :title, :string, required: true
      attribute :profile do
        attribute :email, :string, required: true
        attribute :address do
          attribute :street_name, :string
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

  def test_root_hash
    params = { user: { title: "woo", email: { address: "hmm@yep.com" } } }
    params_filter = params_object(params)
    result = params_filter.accept do
      root :user do
        attribute :title, :string, required: true
        attribute :email do
          attribute :address, :string
          attribute :valid, :boolean
          attribute :ip_address, :string
        end
      end
    end
    expected_result = { title: "woo", email: { address: "hmm@yep.com" } }.to_s

    assert_equal result.to_h.to_s, expected_result
  end

  def test_deeply_nested_errors_and_validity_with_root
    params = {
      user: {
        profile: [
          { address: { street_name: "Main St" } }
        ]
      }
    }
    params_filter = params_object(params)
    result = params_filter.accept do
      root :user do
        attribute :title, :string, required: true
        attribute :profile do
          attribute :email, :string, required: true
          attribute :address do
            attribute :street_name, :string
          end
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

  def test_deeply_nested_errors_and_validity_with_root_with_strict
    params = { user: { profile: [{ address: { street_name: "Main St" } }] } }
    params_filter = params_object(params)

    assert_raises Attribeauty::MissingAttributeError, "title required, email required" do
      params_filter.accept! do
        root :user do
          attribute :title, :string, required: true
          attribute :profile do
            attribute :email, :string, required: true
            attribute :address do
              attribute :street_name, :string, required: false
            end
          end
        end
      end
    end
  end

  def test_with_empty_params
    params = {}
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :title, :string, required: true
      attribute :email do
        attribute :address, :string, required: true
        attribute :valid, :boolean
        attribute :ip_address, :string
      end
    end

    assert_equal result.to_h.to_s, params.to_s
    assert_equal result.errors, ["title required", "address required"]
    assert_equal result.valid?, false
  end

  def test_with_missing_type
    params = { name: "Me" }
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :name
    end

    assert_equal result.to_h.to_s, params.to_s
  end

  def test_with_missing_type_and_exclude_if_nil
    params = { name: "Me", age: nil }
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :name
      attribute :age, exclude_if: :nil?
    end
    expected_result = { name: "Me" }

    assert_equal result.to_h.to_s, expected_result.to_s
  end

  def test_with_default_args_required
    params = { title: "woo", email: { address: "hmm@yep.com" } }
    params_filter = params_object(params)
    result = params_filter.accept required: true do
      attribute :title, :string
      attribute :email do
        attribute :address, :string
        attribute :valid, :boolean
        attribute :ip_address, :string
      end
    end

    assert_equal result.to_h.to_s, params.to_s
    assert_equal result.errors, ["valid required", "ip_address required"]
    assert_equal result.valid?, false
  end

  def test_with_default_args_exclude_if_empty_and_nil
    params = { title: "", email: { address: "hmm@yep.com", ip_address: nil } }
    params_filter = params_object(params)
    result = params_filter.accept exclude_if: %i[nil? empty?] do
      attribute :title, :string
      attribute :email do
        attribute :address, :string
        attribute :valid, :boolean
        attribute :ip_address, :string
      end
    end
    params = { email: { address: "hmm@yep.com" } }

    assert_equal result.to_h.to_s, params.to_s
    assert_equal result.valid?, true
  end

  def test_when_setting_vals
    params = { title: "woo", email: { address: "hmm@yep.com" } }
    params_filter = params_object(params)
    result = params_filter.accept do
      attribute :title, :string, required: true
      attribute :email do
        attribute :address, :string
        attribute :valid, :boolean
        attribute :ip_address, :string
      end
    end
    result[:woo] = "hooo!"
    expected_result = { title: "woo", email: { address: "hmm@yep.com" }, woo: "hooo!" }

    assert_equal result.to_h.to_s, expected_result.to_s
    assert_equal result[:title], "woo"
  end

  def test_with_default_args_exclude_if_empty_and_nil_and_allows
    params = {
      user: {
        username: "user_1",
        full_name: "Full Name",
        bio: "",
        allow_updates: nil,
        email: { address: "hmm@yep.com" }
      }
    }

    params_filter = params_object(params)
    result = params_filter.accept exclude_if: %i[nil? empty?] do
      root :user do
        attribute :username, :string
        attribute :full_name, :string
        attribute :bio, :string, allow: %i[nil? empty?]
        attribute :allow_updates, :boolean
        attribute :email do
          attribute :address, :string
          attribute :valid, :boolean
          attribute :ip_address, :string
        end
      end
    end
    expected_result = {
      username: "user_1",
      full_name: "Full Name",
      bio: "",
      email: { address: "hmm@yep.com" }
    }

    assert_equal result.to_h.to_s, expected_result.to_s
    assert_equal result.valid?, true
  end

  def test_with_default_args_required_and_allows
    params = {
      user: {
        username: "user_1",
        full_name: nil,
        bio: nil,
        allow_updates: nil,
        email: { address: "hmm@yep.com" }
      }
    }

    params_filter = params_object(params)
    result = params_filter.accept required: true do
      root :user do
        attribute :username, :string
        attribute :full_name, :string
        attribute :bio, :string, allow: %i[nil? empty?]
        attribute :allow_updates, :boolean
        attribute :email do
          attribute :address, :string
          attribute :valid, :boolean
          attribute :ip_address, :string
        end
      end
    end
    expected_result = {
      username: "user_1",
      bio: nil,
      email: { address: "hmm@yep.com" }
    }
    errors_array = ["full_name required", "allow_updates required", "valid required", "ip_address required"]

    assert_equal result.to_h.to_s, expected_result.to_s
    assert_equal result.valid?, false
    assert_equal result.errors, errors_array
  end
end
