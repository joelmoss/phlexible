# frozen_string_literal: true

module Phlexible
  module Rails
    # Calls `url_for` for the `href` attribute.
    module AElement
      extend ActiveSupport::Concern

      included do
        include Phlex::Rails::Helpers::URLFor
      end

      def a(href:, **, &)
        super(href: url_for(href), **, &)
      end
    end
  end
end
