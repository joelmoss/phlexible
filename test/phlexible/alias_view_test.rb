# frozen_string_literal: true

require 'test_helper'

class Phlexible::AliasViewTest < ActiveSupport::TestCase
  class IconView < Phlex::HTML
    def view_template
      span { 'I am an icon!' }
      yield if block_given?
    end
  end

  let(:view) do
    Class.new Phlex::HTML do
      extend Phlexible::AliasView

      alias_view :icon, -> { IconView }

      def view_template
        div do
          icon
        end
      end
    end
  end

  let(:view_with_block) do
    Class.new Phlex::HTML do
      extend Phlexible::AliasView

      alias_view :icon, -> { IconView }

      def view_template
        div do
          icon do
            div { 'boo!' }
          end
        end
      end
    end
  end

  it 'defines alias method' do
    render view.new

    assert_equal '<div><span>I am an icon!</span></div>', @response
  end

  describe 'with block' do
    it 'renders the block' do
      render view_with_block.new

      assert_equal '<div><span>I am an icon!</span><div>boo!</div></div>', @response
    end
  end
end
