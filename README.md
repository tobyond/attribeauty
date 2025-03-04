# Attribeauty

A lightweight Ruby gem that provides elegant attribute handling, parameter casting, and validation.

[![Gem Version](https://badge.fury.io/rb/attribeauty.svg)](https://badge.fury.io/rb/attribeauty)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- **Attribeauty::Params**: Type-cast, transform, and validate incoming parameters for any ruby app.

## Installation

Add to your Gemfile:

```ruby
gem 'attribeauty'
```

Then run:

```bash
$ bundle install
```

Or install directly:

```bash
$ gem install attribeauty
```

## Attribeauty::Params

### Overview

`Attribeauty::Params` solves a common problem in web applications: parameters arrive as strings, but your application needs them as proper data types. It elegantly handles:

- Type casting (string → integer, boolean, etc.)
- Required field validation
- Conditional exclusion of nil/empty values
- Nested data structures (hashes and arrays)
- Default values
- Plain ruby compatible

### Basic Usage

***Note the following examples use rails, but also apply to your Roda/Sinatra/Hanami/Rack app***

In a Rails controller:

```ruby
class ApplicationController < ActionController::Base
  private

  def params_filter
    Attribeauty::Params.with(params.to_unsafe_h)
  end
end
```

Then in your specific controllers:

```ruby
class UsersController < ApplicationController
  def create
    if params_filter.errors.any?
      flash[:alert] = params_filter.errors.join(", ")
      render :new
    else
      @user = User.create(user_params)
      redirect_to @user, notice: "User created successfully"
    end
  end

  private

  def user_params
    params_filter.accept do
      root :user do
        attribute :username, :string, required: true
        attribute :age, :integer
        attribute :active, :boolean, default: true
        attribute :email do
          attribute :address, :string, required: true
          attribute :verified, :boolean, default: false
        end
      end
    end
  end
end
```

### Input and Output Examples

**Input params:**
```ruby
{
  'user' => {
    'username' => 'js_bach',
    'age' => '42',
    'job_title' => '',
    'email' => {
      'address' => 'js@bach.music'
    }
  }
}
```

**Output after processing:**
```ruby
{
  username: 'js_bach',
  age: 42,
  active: true,
  email: {
    address: 'js@bach.music',
    verified: false
  }
}
```

### Advanced Features

#### Exclude empty or nil values

```ruby
attribute :job_title, :string, exclude_if: [:nil?, :empty?]
```

#### Apply options globally

```ruby
params_filter.accept(required: true) do
  # All attributes will require values unless overridden
  attribute :username, :string
  attribute :email, :string, allows: :nil? # Exception to the global rule
end
```

#### Raise errors instead of collecting them

```ruby
params_filter.accept! do
  # Will raise Attribeauty::MissingAttributeError if required fields are missing
end
```

#### Handle arrays of objects

```ruby
attribute :addresses do
  attribute :street, :string
  attribute :city, :string
end
```

Works with both single objects and arrays of objects.

### Custom Types

Define your own attribute types:

```ruby
Attribeauty.configure do |config|
  config.types[:email] = MyTypes::Email
end

module MyTypes
  class Email
    def cast(value)
      value.to_s.downcase.strip
    end
  end
end
```

### Rails Integration

```ruby
# config/initializers/attribeauty.rb
Rails.application.reloader.to_prepare do
  Attribeauty.configure do |config|
    config.types[:string] = ActiveModel::Type::String
    config.types[:boolean] = ActiveModel::Type::Boolean
    config.types[:date] = ActiveModel::Type::Date
    config.types[:time] = ActiveModel::Type::Time
    config.types[:datetime] = ActiveModel::Type::DateTime
    config.types[:float] = ActiveModel::Type::Float
    config.types[:integer] = ActiveModel::Type::Integer
  end
end
```

## Development

After checking out the repo:
- Run `bin/setup` to install dependencies
- Run `rake test` to run the tests
- Run `bin/console` for an interactive prompt

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tobyond/attribeauty.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
