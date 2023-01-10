# frozen_string_literal: true

module Phlexible
  # Create an alias at `element` to the `view_class`.
  #
  # So instead of:
  #
  #   def template
  #     div do
  #       render My::Awesome::Component.new
  #     end
  #   end
  #
  # You can instead do:
  #
  #   alias_view :awesome, -> { My::Awesome::Component }
  #
  #   def template
  #     div do
  #       awesome
  #     end
  #   end
  #
  # Just include `Phlexible::Alias` in your view class.
  #
  module Alias
    def self.alias_view(element, view_class)
      define_method element do |*args, **kwargs, &block|
        render view_class.call.new(*args, **kwargs, &block)
      end
    end
  end
end
