# frozen_string_literal: true

require 'phlex/version'

module Phlexible
  module Rails
    # Calls `url_for` for the `href` attribute, and supports a `:back` `href` value.
    module AElement
      extend ActiveSupport::Concern

      included do
        include Phlex::Rails::Helpers::URLFor
      end

      def a(href:, **attrs, &)
        attrs[:href] = href == :back ? _back_url : url_for(href)

        super(**attrs, &)
      end

      private

        JAVASCRIPT_BACK = 'javascript:history.back()'
        private_constant :JAVASCRIPT_BACK

        if Phlex::VERSION >= '2.0.0'
          def _back_url
            _filtered_referrer || safe(JAVASCRIPT_BACK)
          end
        else
          # Wraps a value to bypass Phlex 1.x's javascript: href stripping.
          SafeHref = Struct.new(:value) do
            def to_phlex_attribute_value = value
            def to_s = ''
          end
          private_constant :SafeHref

          def _back_url
            _filtered_referrer || SafeHref.new(JAVASCRIPT_BACK)
          end
        end

        def _filtered_referrer # :nodoc:
          controller = respond_to?(:view_context) ? view_context : helpers

          if controller.respond_to?(:request)
            referrer = controller.request.env['HTTP_REFERER']
            referrer if referrer && URI(referrer).scheme != 'javascript'
          end
        rescue URI::InvalidURIError # rubocop:disable Lint/SuppressedException
        end
    end
  end
end
