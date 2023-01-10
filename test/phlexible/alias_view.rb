# frozen_string_literal: true

describe Phlexible::AliasView do
  extend ViewHelper

  class IconView < Phlex::HTML
    def template
      span { 'I am an icon!' }
    end
  end

  aliased_view = Class.new Phlex::HTML do
    extend Phlexible::AliasView

    alias_view :icon, -> { IconView }

    def template
      div do
        icon
      end
    end
  end

  unaliased_view = Class.new Phlex::HTML do
    def template
      div do
        render IconView.new
      end
    end
  end

  it 'defines alias method' do
    expect(aliased_view.new.call).to be == unaliased_view.new.call
  end
end
