# frozen_string_literal: true

require 'phlex-rails'

module Phlexible
  module Rails
    autoload :ViewAssigns, 'phlexible/rails/view_assigns'
    autoload :ControllerVariables, 'phlexible/rails/controller_variables'
    autoload :Responder, 'phlexible/rails/responder'
    autoload :AElement, 'phlexible/rails/a_element'

    autoload :MetaTagsComponent, 'phlexible/rails/meta_tags_component'
    autoload :ButtonTo, 'phlexible/rails/button_to'
    autoload :ButtonToConcerns, 'phlexible/rails/button_to'

    module ActionController
      autoload :ImplicitRender, 'phlexible/rails/action_controller/implicit_render'
      autoload :MetaTags, 'phlexible/rails/action_controller/meta_tags'
    end
  end
end
