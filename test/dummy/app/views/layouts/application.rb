# frozen_string_literal: true

class Views::Layouts::Application < Phlex::HTML
  def initialize(view)
    @view = view
  end

  def view_template(&)
    div(id: 'app-layout', &)
  end
end
