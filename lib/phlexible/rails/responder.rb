# frozen_string_literal: true

module Phlexible
  module Rails
    module Responder
      # Overridden to support implicit rendering of phlex views.
      def default_render
        return super if format != :html

        if @default_response
          @default_response.call(options)
        elsif !get? && has_errors?
          render_phlex_view({ status: error_status }.merge!(options))
        else
          render_phlex_view options
        end
      end

      # Render the Phlex view with the current resource. Falls back to default controller rendering
      # if no Phlex view exists. Also passes the current resource to the view, which is then
      # available as `@resource`.
      #
      # @see Phlexible::Rails::ActionController::ImplicitRender#render_plex_view
      def render_phlex_view(options)
        controller.instance_variable_set :@resource, @resource
        controller.render_plex_view(options) || controller.render(options)
      end
      alias render render_phlex_view
    end
  end
end
