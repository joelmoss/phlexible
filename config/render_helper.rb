# frozen_string_literal: true

module RenderHelper
  def render_to_html(component)
    view_context.render(component)
  end

  def render_to_nokogiri_fragment(...)
    html = render_to_html(...)
    Nokogiri::HTML5.fragment(html)
  end

  def render_to_nokogiri_document(...)
    html = render_to_html(...)
    Nokogiri::HTML5(html)
  end

  private

  def view_context
    controller.view_context
  end

  def controller
    @controller ||= ActionView::TestCase::TestController.new
  end
end
