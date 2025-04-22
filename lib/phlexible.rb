# frozen_string_literal: true

require_relative 'phlexible/version'
require 'zeitwerk'
require 'rails'
require 'phlex-rails'

loader = Zeitwerk::Loader.for_gem
loader.setup

module Phlexible
end
