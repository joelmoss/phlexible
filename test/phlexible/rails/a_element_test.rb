# frozen_string_literal: true

require 'test_helper'

class Phlexible::Rails::AElementTest < ActiveSupport::TestCase
  let(:subject) { Views::Articles::Link }

  it 'passes href attribute to url_for' do
    output = render_to_fragment subject.new(href: :root, class: :foo)

    assert_equal '<a class="foo" href="/">A link</a>', output.to_s
  end

  it 'supports :back' do
    output = render_to_fragment subject.new(href: :back)

    assert_equal '<a href="javascript:history.back()">A link</a>', output.to_s
  end
end
