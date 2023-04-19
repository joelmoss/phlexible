# frozen_string_literal: true

require 'rails_helper'
require 'phlex/testing/rails/view_helper'
require 'phlex/testing/nokogiri'

describe Phlexible::Rails::ButtonTo do
  include Phlex::Testing::Rails::ViewHelper
  include Phlex::Testing::Nokogiri::FragmentHelper

  it 'renders a form' do
    output = render subject.new('/') { 'My Button' }
    form = output.at_css('form')

    expect(form[:class]).to be == 'button_to'
    expect(form[:action]).to be == '/'
  end

  it 'renders a button' do
    output = render subject.new('/') { 'My Button' }

    expect(output.at_css('button')).to be(:present?)
  end

  with 'options.method = patch' do
    it 'renders a hidden method input' do
      output = render subject.new('/', method: :patch) { 'My Button' }

      expect(output.at_css('form')[:method]).to be == 'post'
      expect(output.at_css('input[name="_method"]')[:value]).to be == 'patch'
    end
  end

  with 'options.method = get' do
    it 'renders a hidden method input' do
      output = render subject.new('/', method: :get) { 'My Button' }

      expect(output.at_css('form')[:method]).to be == 'get'
      expect(output.at_css('input[name="_method"]')).to be(:nil?)
      expect(output.at_css('input[name="authenticity_token"]')).to be(:nil?)
    end
  end

  with 'options.class' do
    it 'renders class name on the button' do
      output = render subject.new('/', class: 'foo') { 'My Button' }

      expect(output.at_css('button')[:class]).to be == 'foo'
    end
  end

  with 'options.form_class' do
    it 'renders class name on the button' do
      output = render subject.new('/', form_class: 'foo') { 'My Button' }

      expect(output.at_css('form')[:class]).to be == 'foo'
    end
  end

  with 'options.data' do
    it 'renders data attribute' do
      output = render subject.new('/', data: { disable_with: 'Please wait...' }) { 'My Button' }

      expect(output.at_css('button')['data-disable-with']).to be == 'Please wait...'
    end
  end

  describe 'CSRF' do
    let(:subject) { Phlexible::Rails::ButtonTo }
    let(:view_context) { controller.view_context }

    it 'renders an authenticity_token input' do
      mock(view_context) do |mock|
        mock.replace(:protect_against_forgery?) { true }
      end

      output = render subject.new('/') { 'My Button' }

      expect(output.at_css('input[name="authenticity_token"]')).not.to be(:nil?)
    end
  end

  describe 'form' do
    let(:subject) { Phlexible::Rails::ButtonTo }

    it 'should have default method' do
      output = render subject.new('/') { 'My Button' }

      expect(output.at_css('form')[:method]).to be == 'post'
    end

    it 'should use method option' do
      output = render subject.new('/', method: 'get') { 'My Button' }

      expect(output.at_css('form')[:method]).to be == 'get'
    end
  end

  describe 'button' do
    let(:subject) { Phlexible::Rails::ButtonTo }

    it 'renders name as the value' do
      output = render subject.new('/') { 'My Button' }

      expect(output.at_css('button').text).to be == 'My Button'
    end
  end
end
