# frozen_string_literal: true

require 'phlex/testing/view_helper'

describe Phlexible::PageTitle do
  include Phlex::Testing::ViewHelper

  view_one = Class.new Phlex::HTML do
    include Phlexible::PageTitle

    self.page_title = 'Page One'

    def template
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
      output = render view_one.new
      expect(output).to be == '<div>Page One</div>'
    end
  end

  describe 'inherited views' do
    it 'should show the page title' do
      output = render view_three.new
      expect(output).to be == '<div>Page Three - Page Two - Page One</div>'
    end
  end
end
