# frozen_string_literal: true

require 'test_helper'

class Phlexible::CallbacksTest < ActiveSupport::TestCase
  let(:view) do
    Class.new Phlex::HTML do
      include Phlexible::Callbacks

      def view_template
        div { 'hello' }
      end
    end
  end

  describe 'before_template' do
    it 'runs callback before template rendering' do
      klass = Class.new(view) do
        before_template :prepend_content

        private

          def prepend_content
            span { 'before' }
          end
      end

      render klass.new

      assert_equal '<span>before</span><div>hello</div>', @response
    end

    it 'runs callback defined with a block' do
      klass = Class.new(view) do
        before_template do
          span { 'before' }
        end
      end

      render klass.new

      assert_equal '<span>before</span><div>hello</div>', @response
    end

    it 'runs multiple callbacks in order' do
      klass = Class.new(view) do
        before_template :first_callback, :second_callback

        private

          def first_callback
            span { 'first' }
          end

          def second_callback
            span { 'second' }
          end
      end

      render klass.new

      assert_equal '<span>first</span><span>second</span><div>hello</div>', @response
    end
  end

  describe 'after_template' do
    it 'runs callback after template rendering' do
      klass = Class.new(view) do
        after_template :append_content

        private

          def append_content
            span { 'after' }
          end
      end

      render klass.new

      assert_equal '<div>hello</div><span>after</span>', @response
    end

    it 'runs callback defined with a block' do
      klass = Class.new(view) do
        after_template do
          span { 'after' }
        end
      end

      render klass.new

      assert_equal '<div>hello</div><span>after</span>', @response
    end
  end

  describe 'around_template' do
    it 'wraps the template rendering' do
      klass = Class.new(view) do
        around_template :wrap_content

        private

          def wrap_content
            span { 'before' }
            yield
            span { 'after' }
          end
      end

      render klass.new

      assert_equal '<span>before</span><div>hello</div><span>after</span>', @response
    end
  end

  describe 'after_initialize' do
    it 'runs callback after initialization' do
      klass = Class.new(view) do
        attr_reader :initialized

        after_initialize :mark_initialized

        private

          def mark_initialized
            @initialized = true
          end
      end

      instance = klass.new
      assert instance.initialized
    end

    it 'runs callback defined with a block' do
      klass = Class.new(view) do
        attr_reader :initialized

        after_initialize do
          @initialized = true
        end
      end

      instance = klass.new
      assert instance.initialized
    end
  end

  describe 'combined callbacks' do
    it 'runs before, around, and after callbacks together' do
      klass = Class.new(view) do
        before_template :prepend_content
        around_template :wrap_content
        after_template :append_content

        private

          def prepend_content
            span { 'before' }
          end

          def wrap_content
            em { 'around-before' }
            yield
            em { 'around-after' }
          end

          def append_content
            span { 'after' }
          end
      end

      render klass.new

      expected = '<span>before</span><em>around-before</em>' \
                 '<div>hello</div><span>after</span><em>around-after</em>'
      assert_equal expected, @response
    end
  end

  describe 'inheritance' do
    it 'inherits callbacks from parent class' do
      parent = Class.new(view) do
        before_template do
          span { 'parent-before' }
        end
      end

      child = Class.new(parent)

      render child.new

      assert_equal '<span>parent-before</span><div>hello</div>', @response
    end

    it 'child can add its own callbacks' do
      parent = Class.new(view) do
        before_template do
          span { 'parent-before' }
        end
      end

      child = Class.new(parent) do
        after_template do
          span { 'child-after' }
        end
      end

      render child.new

      assert_equal '<span>parent-before</span><div>hello</div><span>child-after</span>', @response
    end
  end
end
