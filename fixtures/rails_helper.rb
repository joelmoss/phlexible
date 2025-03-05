# frozen_string_literal: true

Bundler.require :default

Combustion.path = 'fixtures/dummy'

Combustion.initialize! :action_controller do
  config.load_defaults 7.0
  config.autoload_paths << "#{root}/app"
  config.active_support.to_time_preserves_timezone = :zone
end
