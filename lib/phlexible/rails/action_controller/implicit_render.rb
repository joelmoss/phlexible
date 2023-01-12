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
        def default_render
          render_view_class || super
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

        def render_view_class
          phlex_view && render(phlex_view.new)
        end

        def _handle_view_class(*_args)
          render_view_class
        end

        def phlex_view
          @phlex_view ||= "views/#{controller_path}/#{@_action_name}".classify.safe_constantize
        end
      end
    end
  end
end
