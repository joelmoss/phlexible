# frozen_string_literal: true

class Views::Layouts::Admin < Phlex::HTML
  def initialize(view)
    @view = view
  end

  def view_template(&)
    div(id: 'admin-layout', &)
  end
end
