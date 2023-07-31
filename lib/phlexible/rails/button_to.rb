# frozen_string_literal: true

# Generates a form containing a single button that submits to the URL created by the set of options.
# Similar to Rails `button_to` helper.
#
# The form submits a POST request by default. You can specify a different HTTP verb via the :method
# option.
#
# Additional arguments are passed through to the button element, with a few exceptions:
#  - :method - Symbol of HTTP verb. Supported verbs are :post, :get, :delete, :patch, and :put. By
#    default it will be :post.
#  - :form_class - This controls the class of the form within which the submit button will be
#    placed. By default it will be 'button_to'.
#  - :params - Hash of parameters to be rendered as hidden fields within the form.
module Phlexible
  module Rails
    module ButtonToConcerns
      BUTTON_TAG_METHOD_VERBS = %w[patch put delete].freeze
      DEFAULT_OPTIONS = { method: 'post', form_class: 'button_to', params: {} }.freeze

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
          param_inputs

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

      def param_inputs
        return unless (params = @options.delete(:params))

        to_form_params(params).each do |param|
          input type: 'hidden', name: param[:name], value: param[:value], autocomplete: 'off'
        end
      end

      # Returns an array of hashes each containing :name and :value keys
      # suitable for use as the names and values of form input fields:
      #
      #   to_form_params(name: 'David', nationality: 'Danish')
      #   # => [{name: 'name', value: 'David'}, {name: 'nationality', value: 'Danish'}]
      #
      #   to_form_params(country: { name: 'Denmark' })
      #   # => [{name: 'country[name]', value: 'Denmark'}]
      #
      #   to_form_params(countries: ['Denmark', 'Sweden']})
      #   # => [{name: 'countries[]', value: 'Denmark'}, {name: 'countries[]', value: 'Sweden'}]
      #
      # An optional namespace can be passed to enclose key names:
      #
      #   to_form_params({ name: 'Denmark' }, 'country')
      #   # => [{name: 'country[name]', value: 'Denmark'}]
      def to_form_params(attribute, namespace = nil)
        attribute = attribute.to_h if attribute.respond_to?(:permitted?)

        params = []
        case attribute
        when Hash
          attribute.each do |key, value|
            prefix = namespace ? "#{namespace}[#{key}]" : key
            params.push(*to_form_params(value, prefix))
          end
        when Array
          array_prefix = "#{namespace}[]"
          attribute.each do |value|
            params.push(*to_form_params(value, array_prefix))
          end
        else
          params << { name: namespace.to_s, value: attribute.to_param }
        end

        params.sort_by { |pair| pair[:name] }
      end
    end

    class ButtonTo < Phlex::HTML
      include ButtonToConcerns
    end
  end
end
