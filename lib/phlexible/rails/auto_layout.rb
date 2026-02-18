# frozen_string_literal: true

module Phlexible
  module Rails
    module AutoLayout
      extend ActiveSupport::Concern
      include Phlexible::Rails::ViewAssigns
      include Phlexible::Callbacks

      included do
        define_callbacks :layout

        class_attribute :auto_layout_view_prefix, instance_writer: false, default: 'Views::'
        class_attribute :auto_layout_namespace, instance_writer: false, default: 'Views::Layouts::'
        class_attribute :auto_layout_default, instance_writer: false, default: 'Views::Layouts::Application'
      end

      def around_template
        layout_class = controller_assigned_layout || self.class.resolved_layout
        if layout_class
          run_callbacks :layout do
            render(@layout = layout_class.new(self)) { super }
          end
        else
          super
        end
      end

      class_methods do
        def resolved_layout
          if ::Rails.configuration.enable_reloading
            resolve_layout
          else
            return @resolved_layout if defined?(@resolved_layout)

            @resolved_layout = resolve_layout
          end
        end

        def reset_resolved_layout!
          remove_instance_variable(:@resolved_layout) if defined?(@resolved_layout)
        end

        private

          def resolve_layout
            view_name = resolve_view_name
            return nil if view_name.blank?

            prefix = auto_layout_view_prefix
            return nil if prefix && !view_name.start_with?(prefix)

            resolve_layout_from_namespace(view_name, prefix) ||
              auto_layout_default&.safe_constantize
          end

          def resolve_layout_from_namespace(view_name, prefix)
            strip_prefix = prefix || infer_prefix_from_namespace || ''
            segments = view_name.delete_prefix(strip_prefix).split('::')[..-2]

            segments.length.downto(1) do |i|
              klass = "#{auto_layout_namespace}#{segments.first(i).join('::')}".safe_constantize
              return klass if klass.is_a?(Class)
            end

            nil
          end

          def infer_prefix_from_namespace
            root = auto_layout_namespace&.split('::')&.first
            "#{root}::" if root
          end

          def resolve_view_name
            ancestors.each do |ancestor|
              return ancestor.name if ancestor.is_a?(Class) && ancestor.name.present?
            end
            nil
          end
      end

      private

        def controller_assigned_layout
          return nil if !respond_to?(:view_assigns, true)

          view_assigns['layout']
        end
    end
  end
end
