# frozen_string_literal: true

require_relative 'phlexible/version'
require 'phlex'

module Phlexible
  autoload :AliasView, 'phlexible/alias_view'
  autoload :PageTitle, 'phlexible/page_title'
  autoload :Callbacks, 'phlexible/callbacks'
  autoload :Rails, 'phlexible/rails'
end
