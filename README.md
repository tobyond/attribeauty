# Attribeauty

## Params

`Attribeauty::Params` casts your params and removes elements you want to exclude if they are nil or empty.

#### Why is this needed?

`params` arrive in your controllers as strings—whether they represent integers, nil, dates, or anything else. Rails handles coercion at the Model level when these params are assigned as attributes. However, there are often many steps before your params are assigned. `Attribeauty::Params` elegantly ensures that your attributes start in their expected state before continuing their journey to their final destination.

#### Directions

First, let's set a `params_filter` object to accept rails `params.to_unsafe_h` in the `ApplicationController`

```ruby
# app/controllers/application_controller.rb
class ApplicationController
  private

  def params_filter
    Attribeauty::Params.with(params.to_unsafe_h)
  end
end
```

The `params_filter` object here will take any ruby hash, `symbolize` the keys, and is now ready for the structure you want to provide.

If a users controller receives the following params:

```ruby
{
  'user' => {
    'username' => 'js_bach',
    'full_name' => 'Johann Sebastian Bach',
    'job_title' => 'Composer',
    'age' => '43',
    'salary' => nil,
    'email' => {
      'address' => 'js@bach.music'
    }
  }
}
```

We can coerce them with into `create_params` with the following:


```ruby
# app/controllers/my_controller.rb
class UsersController < ApplicationController
  def edit; end

  def update
    @user = Users::Creator.call(create_params)

    if @user.valid?
      redirect_to index_path, notice: 'Welcome to the app'
    else
      flash[:alert] = @user.errors.full_messages
      render :edit
    end
  end

  private

  def create_params
    params_filter.accept do
      root :user do
        attribute :username, :string, required: true
        attribute :full_name, :string
        attribute :job_title, :string, exclude_if: [:nil?, :empty?]
        attribute :age, :integer
        attribute :salary, :integer, exclude_if: :nil?
        attribute :email do
          attribute :address, :string, required: true
          attribute :receive_updates, :boolean, default: false
        end
      end
    end
  end
end
```

The above will return a hash with the `age` integer cast to integer, the `salary` removed, and a `receive_updates` defaulted to `false`. The `root` `user` node will be removed too. If you wish to keep the root node, simply using `attribute` with a `block` will suffice. Below is the output from this:


```ruby
{
  'username' => 'js_bach',
  'full_name' => 'Johann Sebastian Bach',
  'job_title' => 'Composer',
  'age' => 43,
  'email' => {
    'address' => 'js@bach.music',
    'receive_updates' => false
  }
}

```

`Attribeauty::Params` can handle nested arrays and nested hashes with the same `accept`:

```ruby
  # {
  #   "username" => "js_bach",
  #   "full_name" => "Johann Sebastian Bach",
  #   "job_title" => "Composer",
  #   "age" => 43,
  #   "email" => [
  #     { "address" => "js@bach.music", "secondary" => false },
  #     { "address" => "papa@bach.music", "secondary" => true }
  #   ]
  # }
  #
  # or
  #
  # {
  #   "username" => "js_bach",
  #   "full_name" => "Johann Sebastian Bach",
  #   "job_title" => "Composer",
  #   "age" => 43,
  #   "email" => { "address" => "js@bach.music", "secondary" => false }
  # }
  def create_params
    params_filter.accept do
      attribute :username, :string, required: true
      attribute :full_name, :string
      attribute :job_title, :string, exclude_if: [:nil?, :empty?]
      attribute :age, :integer
      attribute :salary, :integer, exclude_if: :nil?
      attribute :email do
        attribute :address, :string, required: true
        attribute :secondary, :boolean, default: false
      end
    end
  end
```

#### Error handling

`Attribeauty::Params` has rudimentary error handling, and will return an errors array when `required: true` values are missing:

```ruby
class MyController
  def edit; end

  def update
    if params_filter.errors.any?
      flash[:alert] = params.errors.join(', ')
      render :edit
    else
      MyRecord::Updater.call(update_params)
      redirect_to index_path
    end
  end

  private

  # with the following params:
  # { user: { username: nil } }

  # update_params.errors => ["username required"]

  def update_params
    params_filter.accept do
      root :user do
        attribute :username, :string, required: true
      end
    end
  end
end

```

#### Raising Errors

If you want to raise an error, rather than just return the errors in an array, use the `accept!` method. Will raise `Attribeauty::MissingAttributeError` with the required elements:


```ruby
class MyController
  def update
    MyRecord::Updater.call(update_params)
    # calling update_params
    # will raise: Attribeauty::MissingAttributeError, "username required"

    redirect_to index_path
  end

  private

  # with the following params:
  # { user: { username: nil } }

  def update_params
    params_filter.accept do
      root :user do
        attribute :username, :string, required: true
      end
    end
  end
end

```

#### Require all

What if you want to require all attributes? If you pass the `required: true` or `exclude_if: :nil?` with the `accept`, it will be applied to all attributes. 
You can also exclude a value from this by using the `allows` option.

```ruby
class MyController
  def update
    MyRecord.update(update_params)
   
    redirect_to index_path
  end

  private

  # with the following params:
  # { user: { profile: [{ address: { street_name: "Main St" } }] } }

  # required: true will be passed onto all attributes, except ip_address
  
  def update_params
    params_filter.accept required: true do
      root :user do
        attribute :title, :string, 
        attribute :email do
          attribute :address, :string
          attribute :valid, :boolean
          attribute :ip_address, :string, allows: :nil?
        end
      end
    end
  end
end

```

See `test/test_params.rb` for more examples


## Base

I needed a straightforward way to initialize mutable objects, and this solution provides exactly that. While there are many existing options (notably the Rails Attributes API), I opted to build my own.


Inherit from `Attribeauty::Base` and then add attribute with the type you want.
Initialize with these and they will be cast to that attribute.
Use `assign_attributes` to update the object.


```ruby
class MyClass < Attribeauty::Base
  attribute :first, :string
  attribute :second, :integer
  attribute :third, :float
  attribute :forth, :boolean
  attribute :fifth, :time
  attribute :sixth, :koala
  attribute :seventh, :string, default: "Kangaroo"
end

instance = MyClass.new(first: 456)
instance.first # => "456"
instance.assign_attributes(second: "456")
instance.second # => 456
instance.first = 9000
instance.first # => "9000"
instance.seventh # => "Kangaroo"
```

To add your own types, simply have a class that handles `MyClassName.new.cast(value)`:

```ruby
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

#### Is this for rails only?
Nope, any ruby program will work with this.

## Installation

Add `attribeauty` to your application's Gemfile and `bundle install` the gem:

```ruby
# Gemfile
gem 'attribeauty'
```

Use bundle to automatically install the gem and add to the application's Gemfile by executing:

```bash
$ bundle add attribeauty
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
$ gem install attribeauty
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tobyond/attribeauty.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
