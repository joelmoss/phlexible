# frozen_string_literal: true

require 'rails_helper'

describe Phlexible::Rails::AnchorElement do
  let(:output) { ArticlesController.render 'index' }

  it 'pass href attribute to url_for' do
    expect(output).to be == '<a href="/">A link to root</a>'
  end
end
