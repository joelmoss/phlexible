# frozen_string_literal: true

class Views::Layouts::Admin::Users < Phlex::HTML
  def initialize(view)
    @view = view
  end

  def view_template(&)
    div(id: 'admin-users-layout', &)
  end
end
