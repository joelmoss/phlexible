# frozen_string_literal: true

class Views::Articles::Link < Phlex::HTML
  include Phlexible::Rails::AElement

  def view_template
    a(href: :root, class: :foo) { 'A link to root' }
  end
end
