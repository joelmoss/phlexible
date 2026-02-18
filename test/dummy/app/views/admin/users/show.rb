# frozen_string_literal: true

class Views::Admin::Users::Show < Phlex::HTML
  include Phlexible::Rails::AutoLayout

  def view_template
    span { 'admin users show' }
  end
end
