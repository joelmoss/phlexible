# frozen_string_literal: true

require 'rails_helper'

describe Phlexible::Rails::HrefAttribute do
  let(:output) { ArticlesController.render 'index' }

  it 'pass href attribute to url_for' do
    expect(output).to be == '<a href="/" class="foo">A link to root</a>'
  end
end
