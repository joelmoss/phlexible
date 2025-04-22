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
#     def view_template
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
      include ViewAssigns

      def self.included(klass)
        klass.class_attribute :__controller_variables__, instance_predicate: false, default: Set.new
        klass.extend ClassMethods
        klass.include Callbacks
        klass.before_template :define_controller_variables
      end

      class UndefinedVariable < NameError
        def initialize(name)
          @variable_name = name
          super("Attempted to expose controller variable `#{@variable_name}`, but instance " \
                'variable is not defined in the controller.')
        end
      end

      private

      def define_controller_variables
        return unless respond_to?(:__controller_variables__)

        view_assigns = view_assigns()
        view = @view

        vars = (view&.__controller_variables__ || Set.new) + __controller_variables__
        vars.each do |k, v|
          allow_undefined = true
          if k.ends_with?('!')
            allow_undefined = false
            k = k.chop
          end

          raise ControllerVariables::UndefinedVariable, k if !allow_undefined && !view_assigns.key?(k)

          instance_variable_set(:"@#{v}", view_assigns[k])
          view&.instance_variable_set(:"@#{v}", view_assigns[k])
        end
      end

      module ClassMethods
        # /*
        def controller_variable(*names, **kwargs)
          if names.empty? && kwargs.empty?
            raise ArgumentError, 'You must provide at least one variable name and/or a hash of ' \
                                 'variable names and options.'
          end

          allow_undefined = kwargs.delete(:allow_undefined)
          as = kwargs.delete(:as)

          if names.count > 1 && as
            raise ArgumentError, 'You cannot provide the `as:` option when passing multiple ' \
                                 'variable names.'
          end

          names.each do |name|
            name_as = as || name
            name = "#{name}!" unless allow_undefined

            self.__controller_variables__ += { name.to_s => name_as.to_s }
          end

          kwargs.each do |k, v|
            if v.is_a?(Hash)
              name = v.key?(:as) ? v[:as].to_s : k.to_s

              if v.key?(:allow_undefined)
                k = "#{k}!" unless v[:allow_undefined]
              elsif !allow_undefined
                k = "#{k}!"
              end
            else
              name = v.to_s
              k = "#{k}!" unless allow_undefined
            end

            self.__controller_variables__ += { k.to_s => name }
          end
        end
      end
    end
  end
end
