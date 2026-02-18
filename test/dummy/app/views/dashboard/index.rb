# frozen_string_literal: true

class Views::Dashboard::Index < Phlex::HTML
  include Phlexible::Rails::AutoLayout

  def view_template
    span { 'dashboard index' }
  end
end
