# frozen_string_literal: true

module Phlexible
  #
  # Create an alias at `element` to the `view_class`.
  #
  # So instead of:
  #
  #   class MyView < Phlex::HTML
  #     def view_template
  #       div do
  #         render My::Awesome::Component.new
  #       end
  #     end
  #   end
  #
  # You can instead do:
  #
  #   class MyView < Phlex::HTML
  #     extend Phlexible::AliasView
  #
  #     alias_view :awesome, -> { My::Awesome::Component }
  #
  #     def view_template
  #       div do
  #         awesome
  #       end
  #     end
  #   end
  #
  module AliasView
    def alias_view(element, view_class)
      define_method element do |*args, **kwargs, &blk|
        render view_class.call.new(*args, **kwargs), &blk
      end
    end
  end
end
