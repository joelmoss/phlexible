# frozen_string_literal: true

describe Phlexible::PageTitle do
  include RenderHelper

  view_one = Class.new Phlex::HTML do
    include Phlexible::PageTitle

    self.page_title = 'Page One'

    def view_template
      div { page_title }
    end
  end

  view_two = Class.new view_one do
    self.page_title = 'Page Two'
  end

  view_three = Class.new view_two do
    self.page_title = 'Page Three'
  end

  describe 'single view' do
    it 'should show the page title' do
      output = render_to_html view_one.new
      expect(output).to be == '<div>Page One</div>'
    end
  end

  describe 'inherited views' do
    it 'should show the page title' do
      output = render_to_html view_three.new
      expect(output).to be == '<div>Page Three - Page Two - Page One</div>'
    end
  end
end
