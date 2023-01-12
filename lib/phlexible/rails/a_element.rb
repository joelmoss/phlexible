# frozen_string_literal: true

module Phlexible
  module Rails
    # Calls `url_for` for the `href` attribute.
    module AElement
      def a(href:, **kwargs, &block)
        super(href: helpers.url_for(href), **kwargs, &block)
      end
    end
  end
end
