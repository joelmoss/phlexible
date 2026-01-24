# frozen_string_literal: true

module Phlexible
  #
  # Helper to assist in defining page titles within Phlex views. Also includes support for nested
  # views, where each desendent view class will have its title prepended to the page title. Simply
  # include the module and assign the title to the `page_title` class variable:
  #
  #   class MyView
  #     include Phlexible::PageTitle
  #     self.page_title = 'My Title'
  #   end
  #
  # Then call the `page_title` method in the <head> of your page.
  #
  module PageTitle
    def self.included(base)
      base.class_eval do
        self.class.attr_accessor :page_title
      end
    end

    private

      def page_title
        title = []

        klass = self.class
        while klass.respond_to?(:page_title)
          title << if klass.page_title.is_a?(Proc)
                     instance_exec(&klass.page_title)
                   else
                     klass.page_title
                   end

          klass = klass.superclass
        end

        title.compact.join(' - ')
      end
  end
end
