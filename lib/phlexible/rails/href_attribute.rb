# frozen_string_literal: true

module Phlexible
  module Rails
    # Calls `url_for` for the `href` attribute.
    module HrefAttribute
      def _attributes(**attributes)
        attributes[:href] = helpers.url_for(attributes[:href]) if attributes.key?(:href)

        super(**attributes)
      end
    end
  end
end
