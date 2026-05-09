# frozen_string_literal: true

require 'test_helper'

class Phlexible::ElementVariantsTest < ActiveSupport::TestCase
  test 'adds data-variant attribute when variant is used' do
    component = Class.new(Phlex::HTML) do
      extend Phlexible::ElementVariants

      variant :divider, on: :h1

      def view_template
        h1(:divider) { 'My Title' }
      end
    end

    assert_equal '<h1 data-variant-divider>My Title</h1>', component.call
  end

  test 'renders without variant when none passed' do
    component = Class.new(Phlex::HTML) do
      extend Phlexible::ElementVariants

      variant :divider, on: :h1

      def view_template
        h1 { 'My Title' }
      end
    end

    assert_equal '<h1>My Title</h1>', component.call
  end

  test 'declaring variant on multiple tags' do
    component = Class.new(Phlex::HTML) do
      extend Phlexible::ElementVariants

      variant :divider, on: %i[h1 h2 h3]

      def view_template
        h1(:divider) { 'One' }
        h2(:divider) { 'Two' }
        h3(:divider) { 'Three' }
      end
    end

    assert_equal '<h1 data-variant-divider>One</h1>' \
                 '<h2 data-variant-divider>Two</h2>' \
                 '<h3 data-variant-divider>Three</h3>', component.call
  end

  test 'block modifies attributes when variant is used' do
    component = Class.new(Phlex::HTML) do
      extend Phlexible::ElementVariants

      variant :external, on: :a do |attributes|
        attributes[:target] = '_blank'
      end

      def view_template
        a(:external, href: '/foo') { 'Link' }
      end
    end

    assert_equal '<a href="/foo" data-variant-external target="_blank">Link</a>', component.call
  end

  test 'block is not invoked when variant is not used' do
    component = Class.new(Phlex::HTML) do
      extend Phlexible::ElementVariants

      variant :external, on: :a do |attributes|
        attributes[:target] = '_blank'
      end

      def view_template
        a(href: '/foo') { 'Link' }
      end
    end

    assert_equal '<a href="/foo">Link</a>', component.call
  end

  test 'applies multiple variants on a single element' do
    component = Class.new(Phlex::HTML) do
      extend Phlexible::ElementVariants

      variant :external, on: :a do |attributes|
        attributes[:target] = '_blank'
      end
      variant :primary, on: :a

      def view_template
        a(:external, :primary, href: '/foo') { 'Link' }
      end
    end

    assert_equal '<a href="/foo" data-variant-external data-variant-primary ' \
                 'target="_blank">Link</a>', component.call
  end

  test 'raises ArgumentError when variant is not registered' do
    component = Class.new(Phlex::HTML) do
      extend Phlexible::ElementVariants

      variant :divider, on: :h1

      def view_template
        h1(:nope) { 'My Title' }
      end
    end

    error = assert_raises(ArgumentError) { component.call }
    assert_match(/Unknown variant `nope` for `h1`/, error.message)
  end

  test 'underscored variant names render with dashes in the data attribute' do
    component = Class.new(Phlex::HTML) do
      extend Phlexible::ElementVariants

      variant :super_big, on: :h1

      def view_template
        h1(:super_big) { 'My Title' }
      end
    end

    assert_equal '<h1 data-variant-super-big>My Title</h1>', component.call
  end

  test 'merges with existing data attributes on the element' do
    component = Class.new(Phlex::HTML) do
      extend Phlexible::ElementVariants

      variant :divider, on: :h1

      def view_template
        h1(:divider, data: { foo: 'bar' }) { 'My Title' }
      end
    end

    assert_equal '<h1 data-foo="bar" data-variant-divider>My Title</h1>', component.call
  end
end
