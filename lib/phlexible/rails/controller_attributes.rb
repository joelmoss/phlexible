# frozen_string_literal: true

# Include this module in your Phlex views to get access to the controller's instance variables. It
# provides an explicit interface for accessing controller instance variables from the view. Simply
# call `controller_attribute` with the name of any controller instance variable you want to access
# in your view.
#
# @example
#   class Views::Users::Index < Views::Base
#     controller_attribute :user_name
#
#     def template
#       h1 { @user_name }
#     end
#   end
#
# Options
#   - `attr_reader:` - If set to `true`, an `attr_reader` will be defined for the given attributes.
#   - `alias:` - If set, the given attribute will be aliased to the given alias value.
#
# NOTE: Phlexible::Rails::ActionController::ImplicitRender is required for this to work.
#
module Phlexible
  module Rails
    module ControllerAttributes
      module Layout
        def self.included(klass)
          klass.extend ClassMethods
        end

        module ClassMethods
          def render(view, _locals)
            component = new

            # Assign controller attributes to the layout.
            view.controller.assign_phlex_accessors component if view.controller.respond_to? :assign_phlex_accessors

            component.call(view_context: view) do |yielded|
              output = yielded.is_a?(Symbol) ? view.view_flow.get(yielded) : yield

              component.unsafe_raw(output) if output.is_a?(ActiveSupport::SafeBuffer)

              nil
            end
          end
        end
      end

      def self.included(klass)
        klass.class_attribute :__controller_attributes__, instance_predicate: false, default: Set.new
        klass.extend ClassMethods
      end

      class UndefinedVariable < NameError
        def initialize(name)
          @variable_name = name
          super "Attempted to expose controller attribute `#{@variable_name}`, but instance " \
                'variable is not defined in the controller.'
        end
      end

      module ClassMethods
        def controller_attribute(*names, **kwargs) # rubocop:disable Metrics/AbcSize,Metrics/PerceivedComplexity
          include Layout if include?(Phlex::Rails::Layout) && !include?(Layout)

          self.__controller_attributes__ += names

          return if kwargs.empty?

          names.each do |name|
            attr_reader name if kwargs[:attr_reader]

            if kwargs[:alias]
              if kwargs[:attr_reader]
                alias_method kwargs[:alias], name
              else
                define_method(kwargs[:alias]) { instance_variable_get :"@#{name}" }
              end
            end
          end
        end
      end
    end
  end
end
