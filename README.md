# Attribeauty

I just wanted a quick, simple way to initialize mutable objects. This is it.
There are so many of these, but none were what I wanted.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add attribeauty

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install attribeauty

## Usage

Inherit from `Attribeauty::Base` and then add attribute with the type you want.
Initialize with these and they will be cast to that attribute.
Use `assign_attributes` to update the object.


```
class MyClass < Attribeauty::Base
  attribute :first, :string
  attribute :second, :integer
  attribute :third, :float
  attribute :forth, :boolean
  attribute :fifth, :time
  attribute :sixth, :koala
end

instance = MyClass.new(first: 456)
instance.first # => "456"
instance.assign_attributes(second: "456")
instance.second # => 456
instance.first = 9000
instance.first # => "9000"
```

To add your own types, simply have a class that handles `MyClassName.new.cast(value)`:

```
Attribeauty.configure do |config|
  config.types[:koala] = MyTypes::Koala
end

module MyTypes
  class Koala
    def cast(value)
      value.inspect.to_s << "_koalas"
    end
  end
end

class MyClass < Attribeauty::Base
  attribute :wild_animal, :koala
end

instance = MyClass.new(wild_animal: "the_wildest_animals_are")
instance.wild_animal # => "the_wildest_animals_are_koalas"

```

To use rails types add to your config:
```
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

## Params

Experimental params sanitizer is now available. This will cast your params, and remove elements you want to exclude if `nil` or `empty`

```
# app/controllers/my_controller.rb
class MyController
  def update
    MyRecord.update(update_params)
   
    redirect_to index_path
  end

  private

  def params_filter
    Attribeauty::Params.with(request.params)
  end

  def update_params
    params_filter.accept do
      attribute :title, :string, allow_nil: false, required: true
      attribute :email do
        attribute :address, :string, allow_empty: false
        attribute :valid, :boolean, allow_nil: false
        attribute :ip_address, :string, allow_blank: true
      end
    end
  end
```

See `test/test_params.rb` for what is expected.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tobyond/attribeauty.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
