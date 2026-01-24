# frozen_string_literal: true

require 'test_helper'

class Phlexible::ProcessAttributesTest < ActiveSupport::TestCase
  test 'process_attributes' do
    component = Class.new(Phlex::HTML) do
      extend Phlexible::ProcessAttributes

      register_element :foo

      def process_attributes(attrs)
        attrs.tap do |x|
          x[:last_name] = 'Moss' if x[:first_name] == 'Joel'
          x[:last_name] = 'Lees' if x[:first_name] == 'Sam'
        end
      end

      def view_template
        foo(first_name: 'Joel') { 'hello' }
        i(first_name: 'Sam') { 'hello' }
      end
    end

    assert_equal <<~HTML.chop, component.call
      <foo first-name="Joel" last-name="Moss">hello</foo><i first-name="Sam" last-name="Lees">hello</i>
    HTML
  end
end
