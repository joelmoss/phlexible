# frozen_string_literal: true

# Generates a form containing a single button that submits to the URL created by the set of options.
# Similar to Rails `button_to` helper.
#
# The form submits a POST request by default. You can specify a different HTTP verb via the :method
# option.
module Phlexible
  module Rails
    module ButtonToConcerns
      BUTTON_TAG_METHOD_VERBS = %w[patch put delete].freeze
      DEFAULT_OPTIONS = { method: 'post', form_class: 'button_to' }.freeze

      def initialize(url, options = nil)
        @url = url
        @options = options
      end

      # rubocop:disable Metrics/AbcSize
      def template(&block)
        action = helpers.url_for(@url)
        @options = DEFAULT_OPTIONS.merge((@options || {}).symbolize_keys)

        method = (@options.delete(:method).presence || method_for_options(@options)).to_s
        form_method = method == 'get' ? 'get' : 'post'

        form action: action, class: @options.delete(:form_class), method: form_method do
          method_tag method
          form_method == 'post' && token_input(action, method.empty? ? 'post' : method)

          block_given? ? button(**button_attrs, &block) : button(**button_attrs) { @name }
        end
      end
      # rubocop:enable Metrics/AbcSize

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

    class ButtonTo < Phlex::HTML
      include ButtonToConcerns
    end
  end
end
