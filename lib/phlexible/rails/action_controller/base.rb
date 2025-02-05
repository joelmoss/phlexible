# frozen_string_literal: true

module Phlexible
  module Rails
    module ActionController
      module Base

        protected

        def phlex_view(options)
          phlex_view_path(options)&.camelize&.safe_constantize
        end

        def phlex_view_path(options)
          if options[:action]
            "/#{controller_path}/#{options[:action]}_view"
          elsif options[:template]
            "/#{options[:template]}_view"
          end
        end
      end
    end
  end
end
