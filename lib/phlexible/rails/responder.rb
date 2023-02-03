# frozen_string_literal: true

module Phlexible
  module Rails
    module Responder
      # Overridden to support implicit rendering of phlex views.
      def default_render
        if @default_response
          @default_response.call(options)
        elsif !get? && has_errors?
          render_phlex_view options.merge(status: :unprocessable_entity)
        else
          render_phlex_view options
        end
      end

      # Render the Phlex view with the current resource. Falls back to default controller rendering if
      # no Phlex view exists.
      #
      # @see Phlexible::Rails::ActionController::ImplicitRender#render_view_class
      def render_phlex_view(options)
        controller.render_view_class(@resource, options) || controller.render(options)
      end
      alias render render_phlex_view
    end
  end
end
