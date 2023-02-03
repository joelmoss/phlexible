# frozen_string_literal: true

require 'phlex-rails'

module Phlexible
  module Rails
    autoload :Responder, 'phlexible/rails/responder'
    autoload :AElement, 'phlexible/rails/a_element'
    autoload :ButtonTo, 'phlexible/rails/button_to'

    module ActionController
      autoload :ImplicitRender, 'phlexible/rails/action_controller/implicit_render'
    end
  end
end
