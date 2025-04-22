module Phlexible
  module Rails
    module ViewAssigns

      def view_assigns
        if respond_to?(:view_context)
          # Phlex 2
          view_context.controller.view_assigns
        else
          # Phlex 1
          helpers.controller.view_assigns
        end
      end

    end
  end
end
