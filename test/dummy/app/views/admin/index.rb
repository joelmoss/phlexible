# frozen_string_literal: true

class Views::Admin::Index < Phlex::HTML
  include Phlexible::Rails::AutoLayout

  def view_template
    span { 'admin index' }
  end
end
