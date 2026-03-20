# frozen_string_literal: true

class Views::Articles::Link < Phlex::HTML
  include Phlexible::Rails::AElement

  def initialize(**attrs)
    @attributes = attrs
  end

  def view_template
    a(**@attributes) { 'A link' }
  end
end
