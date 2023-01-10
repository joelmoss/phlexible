# frozen_string_literal: true

class Views::Articles::Link < Phlex::HTML
  include Phlexible::Rails::AnchorElement

  def template
    a(href: :root) { 'A link to root' }
  end
end
