# Phlexible

A bunch of helpers and goodies intended to make life with [Phlex](https://phlex.fun) even easier!

## Installation

Install the gem and add to the application's Gemfile by executing:

`bundle add phlexible`

If bundler is not being used to manage dependencies, install the gem by executing:

`$ gem install phlexible`

## Usage

### Rails

#### `ActionController::ImplicitRender`

Adds support for default and `action_missing` rendering of Phlex views. So instead of this:

```ruby
class UsersController
  def index
    render Views::Users::Index.new
  end
end
```

You can do this:

```ruby
class UsersController
  include Phlexible::Rails::ActionController::ImplicitRender
end
```

#### `Callbacks`

While Phlex does have `before_template`, `after_template`, and `around_template` hooks, they must be defined as regular Ruby methods, meaning you have to always remember to call `super` when redefining any hook method.

This module provides a more Rails-like interface for defining callbacks in your Phlex views, using `ActiveSupport::Callbacks`. It implements the same `before_template`, `after_template`, and `around_template` hooks as callbacks.

```ruby
class Views::Users::Index < Views::Base
  include Phlexible::Callbacks

  before_template :set_title

  def view_template
    h1 { @title }
  end

  private

    def set_title
      @title = 'Users'
    end
end
```

You can still use the regular `before_template`, `after_template`, and `around_template` hooks as well, but I recommend that if you include this module, that you use callbacks instead.

#### `ControllerVariables`

> Available in **>= 1.0.0**

> **NOTE:** Prior to **1.0.0**, this module was called `ControllerAttributes` with a very different API. This is no longer available since **1.0.0**.

Include this module in your Phlex views to get access to the controller's instance variables. It provides an explicit interface for accessing controller instance variables from within the view.

```ruby
class Views::Users::Index < Views::Base
  include Phlexible::Rails::ControllerVariables

  controller_variable :first_name, :last_name

  def view_template
    h1 { "#{@first_name} #{@last_name}" }
  end
end
```

##### Options

`controller_variable` accepts one or many symbols, or a hash of symbols to options.

- `as:` - If set, the given attribute will be renamed to the given value. Helpful to avoid naming conflicts.
- `allow_undefined:` - By default, if the instance variable is not defined in the controller, an
  exception will be raised. If this option is to `true`, an error will not be raised.

You can also pass a hash of attributes to `controller_variable`, where the key is the controller
attribute, and the value is the renamed value, or options hash.

```ruby
class Views::Users::Index < Views::Base
  include Phlexible::Rails::ControllerVariables

  controller_variable last_name: :surname, first_name: { as: :given_name, allow_undefined: true }

  def view_template
    h1 { "#{@given_name} #{@surname}" }
  end
end
```

Please note that defining a variable with the same name as an existing variable in the view will be overwritten.

#### `Responder`

If you use [Responders](https://github.com/heartcombo/responders), Phlexible provides a responder to support implicit rendering similar to `ActionController::ImplicitRender` above. It will render the Phlex view using `respond_with` if one exists, and fall back to default rendering.

Just include it in your ApplicationResponder:

```ruby
class ApplicationResponder < ActionController::Responder
  include Phlexible::Rails::ActionController::ImplicitRender
  include Phlexible::Rails::Responder
end
```

Then simply `respond_with` in your action method as normal:

```ruby
class UsersController < ApplicationController
  def new
    respond_with User.new
  end

  def index
    respond_with User.all
  end
end
```

This responder requires the use of `ActionController::ImplicitRender`, so don't forget to include that in your `ApplicationController`.

If you use `ControllerVariables` in your view, and define a `resource` attribute, the responder will pass that to your view.

#### `AElement`

No need to call Rails `link_to` helper, when you can simply render an anchor tag directly with Phlex. But unfortunately that means you lose some of the magic that `link_to` provides. Especially the automatic resolution of URL's and Rails routes.

The `Phlexible::Rails::AElement` module passes through the `href` attribute to Rails `url_for` helper. So you can do this:

```ruby
Rails.application.routes.draw do
  resources :articles
end
```

```ruby
class MyView < Phlex::HTML
  include Phlexible::Rails::AElement

  def view_template
    a(href: :articles) { 'View articles' }
  end
end
```

#### 'ButtonTo`

Generates a form containing a single button that submits to the URL created by the set of options.

It is similar to Rails `button_to` helper, which accepts the URL or route helper as the first argument, and the value/content of the button as the block.

```ruby
Phlexible::Rails::ButtonTo.new(:root) { 'My Button' }
```

The url argument accepts the same options as Rails `url_for`.

The form submits a POST request by default. You can specify a different HTTP verb via the :method option.

```ruby
Phlexible::Rails::ButtonTo.new(:root, method: :patch) { 'My Button' }
```

##### Options

- `:class` - Specify the HTML class name of the button (not the form).
- `:form_attributes` - Hash of HTML attributes for the form tag.
- `:data` - This option can be used to add custom data attributes.
- `:params` - Hash of parameters to be rendered as hidden fields within the form.
- `:method` - Symbol of the HTTP verb. Supported verbs are :post (default), :get, :delete, :patch,
  and :put.

#### `MetaTags`

> Available in **>= 1.0.0**

A super simple way to define and render meta tags in your Phlex views. Just render the
`Phlexible::Rails::MetaTagsComponent` component in the head element of your page, and define the
meta tags using the `meta_tag` method in your controllers.

```ruby
class MyController < ApplicationController
  meta_tag :description, 'My description'
  meta_tag :keywords, 'My keywords'
end
```

```ruby
class MyView < Phlex::HTML
  def view_template
    html do
      head do
        render Phlexible::Rails::MetaTagsComponent
      end
      body do
        # ...
      end
    end
  end
end
```

### `AliasView`

Create an alias at a given `element`, to the given view class.

So instead of:

```ruby
class MyView < Phlex::HTML
  def view_template
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

  def view_template
    div do
      awesome
    end
  end
end
```

### PageTitle

Helper to assist in defining page titles within Phlex views. Also includes support for nested views, where each desendent view class will have its title prepended to the page title. Simply assign the title to the `page_title` class variable:

```ruby
class MyView
  self.page_title = 'My Title'
end
```

Then call the `page_title` method in the `<head>` of your page.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/joelmoss/phlexible>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/joelmoss/phlexible/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Phlexible project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/joelmoss/phlexible/blob/master/CODE_OF_CONDUCT.md).
