# frozen_string_literal: true

module Phlexible
  module Rails
    # Calls `url_for` for the `href` attribute.
    module AElement
      def a(href:, **, &)
        super(href: helpers.url_for(href), **, &)
      end
    end
  end
end
