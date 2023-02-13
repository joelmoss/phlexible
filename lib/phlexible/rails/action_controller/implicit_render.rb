# frozen_string_literal: true

# Adds support for default and action_missing rendering of Phlex views. So instead of this:
#
#   class UsersController
#     def index
#       render Views::Users::Index.new
#     end
#   end
#
# You can do this:
#
#   class UsersController
#   end
#
module Phlexible
  module Rails
    module ActionController
      module ImplicitRender
        NUFFIN = 'NUFFIN'

        def default_render
          render_view_class || super
        end

        # Renders the Phlex view.
        def render_view_class(view_options = NUFFIN, render_options = {})
          klass = render_options&.key?(:action) ? phlex_view(render_options[:action]) : phlex_view
          return unless klass

          if view_options == NUFFIN
            view_options = render_options.delete(:view_options)
            render klass.new(view_options), render_options
          else
            kwargs = {}
            kwargs = render_options.delete(:view_options) if render_options.key?(:view_options)

            render klass.new(view_options, **kwargs), render_options
          end
        end

        private

        def method_for_action(action_name)
          if action_method?(action_name)
            action_name
          elsif phlex_view
            '_handle_view_class'
          elsif respond_to?(:action_missing, true)
            '_handle_action_missing'
          end
        end

        def _handle_view_class(*_args)
          render_view_class
        end

        def phlex_view(action_name = @_action_name)
          "views/#{controller_path}/#{action_name}".classify.safe_constantize
        end
      end
    end
  end
end
