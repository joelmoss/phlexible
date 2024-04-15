# frozen_string_literal: true

require 'phlex/testing/view_helper'

describe Phlexible::AliasView do
  include Phlex::Testing::ViewHelper

  class IconView < Phlex::HTML
    def view_template
      # pp 1, block
      span { 'I am an icon!' }
      yield if block_given?
    end
  end

  view = Class.new Phlex::HTML do
    extend Phlexible::AliasView

    alias_view :icon, -> { IconView }

    def view_template
      div do
        icon
      end
    end
  end

  view_with_block = Class.new Phlex::HTML do
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

  it 'defines alias method' do
    output = render(view.new)

    expect(output).to be == '<div><span>I am an icon!</span></div>'
  end

  with 'block' do
    it 'renders the block' do
      output = render(view_with_block.new)

      expect(output).to be == '<div><span>I am an icon!</span><div>boo!</div></div>'
    end
  end
end
