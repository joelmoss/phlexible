# frozen_string_literal: true

# Include this module in your Phlex views to get access to the controller's instance variables. It
# provides an explicit interface for accessing controller instance variables from the view. Simply
# call `controller_variable` with the name of any controller instance variable you want to access
# in your view.
#
# @example
#   class Views::Users::Index < Views::Base
#     controller_variable :user_name
#
#     def template
#       h1 { @user_name }
#     end
#   end
#
# Options
#   - `as:` - If set, the given attribute will be renamed to the given value. Helpful to avoid
#     naming conflicts.
#   - `allow_undefined:` - If set to `true`, the view will not raise an error if the controller
#     instance variable is not defined.
#
module Phlexible
  module Rails
    module ControllerVariables
      def self.included(klass)
        klass.class_attribute :__controller_variables__, instance_predicate: false, default: Set.new
        klass.extend ClassMethods
      end

      class UndefinedVariable < NameError
        def initialize(name)
          @variable_name = name
          super "Attempted to expose controller variable `#{@variable_name}`, but instance " \
                'variable is not defined in the controller.'
        end
      end

      def before_template # rubocop:disable Metrics/AbcSize
        if respond_to?(:__controller_variables__)
          view_assigns = helpers.controller.view_assigns

          __controller_variables__.each do |k, v|
            allow_undefined = true
            if k.ends_with?('!')
              allow_undefined = false
              k = k.chop
            end

            raise ControllerVariables::UndefinedVariable, k if !allow_undefined && !view_assigns.key?(k)

            instance_variable_set(:"@#{v}", view_assigns[k]) unless instance_variable_defined?(:"@#{v}")
          end
        end

        super
      end

      module ClassMethods
        def controller_variable(*names, **kwargs) # rubocop:disable Metrics
          if names.empty? && kwargs.empty?
            raise ArgumentError, 'You must provide at least one variable name or a hash of ' \
                                 'variable names and options.'
          end

          allow_undefined = kwargs.delete(:allow_undefined)

          if names.empty?
            kwargs.each do |k, v|
              if v.is_a?(Hash)
                name = v.key?(:as) ? v[:as].to_s : k.to_s

                if v.key?(:allow_undefined)
                  k = "#{k}!" unless v[:allow_undefined] # rubocop:disable Metrics/BlockNesting
                elsif !allow_undefined
                  k = "#{k}!"
                end
              else
                name = v.to_s
                k = "#{k}!" unless allow_undefined
              end

              self.__controller_variables__ += { k.to_s => name }
            end

            if kwargs.key?(:as)
              raise ArgumentError, 'You cannot provide the `as:` option when passing multiple ' \
                                   'variable names.'
            end
          else
            if names.count > 1 && kwargs.key?(:as)
              raise ArgumentError, 'You cannot provide the `as:` option when passing multiple ' \
                                   'variable names.'
            end

            names.each do |name|
              as = kwargs[:as] || name
              name = "#{name}!" unless allow_undefined

              self.__controller_variables__ += { name.to_s => as.to_s }
            end
          end
        end
      end
    end
  end
end
