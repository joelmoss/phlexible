# frozen_string_literal: true

require 'active_support/callbacks'

module Phlexible
  module Callbacks
    extend ActiveSupport::Concern
    include ActiveSupport::Callbacks

    included do
      define_callbacks :initialize, :template
    end

    class_methods do
      def new(...)
        obj = super
        obj.run_callbacks :initialize, :after
        obj
      end

      def after_initialize(*names, &block)
        set_callback(:initialize, :after, *names, &block)
      end

      def around_template(*names, &block)
        set_callback(:template, :around, *names, &block)
      end

      def before_template(*names, &block)
        set_callback(:template, :before, *names, &block)
      end

      def after_template(*names, &block)
        set_callback(:template, :after, *names, &block)
      end

      def before_layout(*names, &block)
        set_callback(:layout, :before, *names, &block)
      end

      def after_layout(*names, &block)
        set_callback(:layout, :after, *names, &block)
      end

      def around_layout(*names, &block)
        set_callback(:layout, :around, *names, &block)
      end
    end

    def around_template
      run_callbacks :template do
        super
      end
    end
  end
end
