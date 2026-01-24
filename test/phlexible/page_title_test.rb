# frozen_string_literal: true

require 'test_helper'

class Phlexible::PageTitleTest < ActiveSupport::TestCase
  let(:view_one) do
    Class.new Phlex::HTML do
      include Phlexible::PageTitle

      self.page_title = 'Page One'

      def view_template
        div { page_title }
      end
    end
  end

  let(:view_two) do
    Class.new view_one do
      self.page_title = 'Page Two'
    end
  end

  let(:view_three) do
    Class.new view_two do
      self.page_title = 'Page Three'
    end
  end

  describe 'single view' do
    it 'shows the page title' do
      render view_one.new

      assert_equal '<div>Page One</div>', @response
    end
  end

  describe 'inherited views' do
    it 'shows the page title' do
      render view_three.new

      assert_equal '<div>Page Three - Page Two - Page One</div>', @response
    end
  end
end
