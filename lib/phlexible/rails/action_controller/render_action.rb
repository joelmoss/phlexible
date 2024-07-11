# frozen_string_literal: true


require_relative "base"

module Phlexible
  module Rails
    module ActionController
      module RenderAction
        include Base

        def render_to_body(options = {})
          if view = phlex_view(options)
            render view.new(**options.except(:action, :prefixes, :template, :layout))
          else
            super
          end
        end
      end
    end
  end
end