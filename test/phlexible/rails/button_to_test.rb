# frozen_string_literal: true

require 'test_helper'

class Phlexible::Rails::ButtonToTest < ActiveSupport::TestCase
  let(:subject) { Phlexible::Rails::ButtonTo }

  it 'renders a form' do
    output = render_to_fragment subject.new('/') { 'My Button' }
    form = output.at_css('form')

    assert_equal 'button_to', form[:class]
    assert_equal '/', form[:action]
  end

  it 'renders a button' do
    output = render_to_fragment subject.new('/') { 'My Button' }

    assert_predicate output.at_css('button'), :present?
  end

  describe 'options.method = patch' do
    it 'renders a hidden method input' do
      output = render_to_fragment subject.new('/', method: :patch) { 'My Button' }

      assert_equal 'post', output.at_css('form')[:method]
      assert_equal 'patch', output.at_css('input[name="_method"]')[:value]
    end
  end

  describe 'options.method = get' do
    it 'renders a hidden method input' do
      output = render_to_fragment subject.new('/', method: :get) { 'My Button' }

      assert_equal 'get', output.at_css('form')[:method]
      assert_equal 'button_to', output.at_css('form')[:class]
      assert_nil output.at_css('input[name="_method"]')
      assert_nil output.at_css('input[name="authenticity_token"]')
    end
  end

  describe 'options.class' do
    it 'renders class name on the button' do
      output = render_to_fragment subject.new('/', class: 'foo') { 'My Button' }

      assert_equal 'foo', output.at_css('button')[:class]
    end
  end

  describe 'options.form_class' do
    it 'renders class name on the form' do
      output = render_to_fragment subject.new('/', form_class: 'foo') { 'My Button' }

      assert_equal 'foo', output.at_css('form')[:class]
    end
  end

  describe 'options.form_attributes' do
    it 'passes attributes to form' do
      output = render_to_fragment subject.new('/', form_attributes: { id: 'foo' }) {
        'My Button'
      }

      assert_equal 'foo', output.at_css('form')[:id]
    end
  end

  describe 'options.data' do
    it 'renders data attribute' do
      output = render_to_fragment subject.new(
        '/',
        data: { disable_with: 'Please wait...' }
      ) {
        'My Button'
      }

      assert_equal 'Please wait...', output.at_css('button')['data-disable-with']
    end
  end

  describe 'options.params' do
    it 'renders hidden input for each' do
      output = render_to_fragment subject.new('/', params: { name: 'Joel' }) {
        'My Button'
      }

      assert_equal 'Joel', output.at_css('input[name="name"]')['value']
    end
  end

  describe 'CSRF' do
    it 'renders an authenticity_token input' do
      controller.stub(:protect_against_forgery?, true) do
        output = render_to_fragment subject.new('/') { 'My Button' }

        assert_not_nil output.at_css('input[name="authenticity_token"]')
      end
    end
  end

  describe 'form' do
    it 'has default method' do
      output = render_to_fragment subject.new('/') { 'My Button' }

      assert_equal 'post', output.at_css('form')[:method]
    end

    it 'uses method option' do
      output = render_to_fragment subject.new('/', method: 'get') { 'My Button' }

      assert_equal 'get', output.at_css('form')[:method]
    end
  end

  describe 'button' do
    it 'renders name as the value' do
      output = render_to_fragment subject.new('/') { 'My Button' }

      assert_equal 'My Button', output.at_css('button').text
    end
  end
end
