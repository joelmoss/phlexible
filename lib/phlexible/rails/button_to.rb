# frozen_string_literal: true

# Generates a form containing a single button that submits to the URL created by the set of options.
# Similar to Rails `button_to` helper.
#
# The form submits a POST request by default. You can specify a different HTTP verb via the :method
# option.
module Phlexible
  module Rails
    class ButtonTo < Phlex::HTML
      BUTTON_TAG_METHOD_VERBS = %w[patch put delete].freeze
      DEFAULT_OPTIONS = { method: 'post' }.freeze

      def initialize(name = nil, url = nil, options = nil)
        @name = name
        @url = url
        @options = options
      end

      def template(&block)
        if block_given?
          @options = @url
          @url = @name
          @name = nil
        end

        action = helpers.url_for(@url)
        @options = DEFAULT_OPTIONS.merge((@options || {}).symbolize_keys)

        method = (@options.delete(:method).presence || method_for_options(@options)).to_s
        form_method = method == 'get' ? 'get' : 'post'

        form action: action, class: 'button_to', method: form_method do
          method_tag method
          form_method == 'post' && token_input(action, method.empty? ? 'post' : method)

          block_given? ? button(**button_attrs, &block) : button(**button_attrs) { @name }
        end
      end

      private

      def button_attrs
        {
          type: 'submit',
          **@options
        }
      end

      def method_for_options(options)
        if options.is_a?(Array)
          method_for_options(options.last)
        elsif options.respond_to?(:persisted?)
          options.persisted? ? :patch : :post
        elsif options.respond_to?(:to_model)
          method_for_options(options.to_model)
        end
      end

      def token_input(action, method)
        return unless helpers.protect_against_forgery?

        name = helpers.request_forgery_protection_token.to_s
        value = helpers.form_authenticity_token(form_options: { action: action, method: method })

        input type: 'hidden', name: name, value: value, autocomplete: 'off'
      end

      def method_tag(method)
        return unless BUTTON_TAG_METHOD_VERBS.include?(method)

        input type: 'hidden', name: '_method', value: method.to_s, autocomplete: 'off'
      end
    end
  end
end
