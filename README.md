# Phlexible

A bunch of helpers and goodies intended to make life with [Phlex](https://phlex.fun) even easier!

## Installation

Install the gem and add to the application's Gemfile by executing:

`bundle add phlexible`

If bundler is not being used to manage dependencies, install the gem by executing:

`$ gem install phlexible`

## Usage

### Rails

#### `AElement`

No need to call Rails `link_to` helper, when you can simply render an anchor tag directly with
Phlex. But unfortunately that means you lose some of the magic that `link_to` provides. Especially
the automatic resolution of URL's and Rails routes.

The `Phlexible::Rails::AElement` module passes through the `href` attribute to Rails `url_for`
helper. So you can do this:

```ruby
Rails.application.routes.draw do
  resources :articles
end
```

```ruby
class MyView < Phlex::HTML
    include Phlexible::Rails::AElement

    def template
        a(href: :articles) { 'View articles' }
    end
end
```

### `AliasView`

Create an alias at a given `element`, to the given view class.

So instead of:

```ruby
class MyView < Phlex::HTML
    def template
        div do
            render My::Awesome::Component.new
        end
    end
end
```

You can instead do:

```ruby
class MyView < Phlex::HTML
    extend Phlexible::AliasView

    alias_view :awesome, -> { My::Awesome::Component }

    def template
        div do
            awesome
        end
    end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joelmoss/phlexible. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/joelmoss/phlexible/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Phlexible project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/joelmoss/phlexible/blob/master/CODE_OF_CONDUCT.md).
