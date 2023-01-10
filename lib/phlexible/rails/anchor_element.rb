# frozen_string_literal: true

module Phlexible
  module Rails
    module AnchorElement
      # @override Calls `url_for` for the :href attribute.
      def a(**attributes, &block)
        attributes[:href] = helpers.url_for(attributes[:href]) if attributes.key?(:href)

        super(**attributes, &block)
      end
    end
  end
end
