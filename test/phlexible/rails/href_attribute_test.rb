# frozen_string_literal: true

require 'test_helper'

class Phlexible::Rails::AElementTest < ActiveSupport::TestCase
  let(:output) { ArticlesController.render('index').strip }

  it 'passes href attribute to url_for' do
    assert_equal '<a href="/" class="foo">A link to root</a>', output
  end
end
