# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require_relative '../test/dummy/config/environment'
require 'rails/test_help'
require 'minitest/difftastic'
require 'maxitest/autorun'

module ActiveSupport
  class TestCase
    private

      def render_to_fragment(...)
        html = render(...)
        Nokogiri::HTML5.fragment(html)
      end

      def render(...)
        @response = view_context.render(...)
      end

      delegate :view_context, to: :controller

      def controller
        @controller ||= ActionView::TestCase::TestController.new
      end
  end
end
