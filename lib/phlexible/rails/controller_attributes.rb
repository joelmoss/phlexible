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
module Phlexible
  module Rails
    module ControllerAttributes
      extend ActiveSupport::Concern

      included do
        class_attribute :__controller_attributes__, instance_predicate: false, default: Set.new
      end

      class_methods do
        def controller_attribute(*names, **kwargs)
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
