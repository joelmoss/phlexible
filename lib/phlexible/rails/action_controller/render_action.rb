module Phlexible
  module Rails
    module ActionController
      module RenderAction

        def render_to_body(options = {})
          if view = phlex_view(options)
            render view.new(**options.except(:action, :prefixes, :template, :layout))
          else
            super
          end
        end

        private

        def phlex_view(options)
          phlex_view_path(options)&.camelize&.safe_constantize
        end

        def phlex_view_path(options)
          if options[:action]
            "/#{controller_path}/#{options[:action]}_view"
          elsif options[:template]
            "/#{options[:template]}_view"
          end
        end
      end
    end
  end
end