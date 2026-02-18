# frozen_string_literal: true

require 'test_helper'

class Phlexible::Rails::AutoLayoutTest < ActiveSupport::TestCase
  describe 'layout resolution' do
    it 'resolves layout from view namespace' do
      render Views::Admin::Index.new

      assert_equal '<div id="admin-layout"><span>admin index</span></div>', @response
    end

    it 'resolves most specific layout first' do
      render Views::Admin::Users::Show.new

      assert_equal '<div id="admin-users-layout"><span>admin users show</span></div>', @response
    end

    it 'falls back to less specific layout when most specific does not exist' do
      # Views::Admin::Settings does not have a matching layout, should fall back to Admin
      stub_const('Views::Admin::Settings', Module.new)
      klass = Class.new(Phlex::HTML) do
        include Phlexible::Rails::AutoLayout

        def view_template
          span { 'admin settings' }
        end
      end
      Views::Admin::Settings.const_set(:Index, klass)

      render klass.new

      assert_equal '<div id="admin-layout"><span>admin settings</span></div>', @response
    ensure
      if Views::Admin::Settings.const_defined?(:Index)
        Views::Admin::Settings.send(:remove_const, :Index)
      end
      Views::Admin.send(:remove_const, :Settings) if Views::Admin.const_defined?(:Settings)
    end

    it 'falls back to default layout when no namespace match' do
      render Views::Dashboard::Index.new

      assert_equal '<div id="app-layout"><span>dashboard index</span></div>', @response
    end

    it 'renders without layout when default is nil and no namespace match' do
      Views::Dashboard::Index.auto_layout_default = nil
      Views::Dashboard::Index.reset_resolved_layout!

      render Views::Dashboard::Index.new

      assert_equal '<span>dashboard index</span>', @response
    ensure
      Views::Dashboard::Index.auto_layout_default = 'Views::Layouts::Application'
      Views::Dashboard::Index.reset_resolved_layout!
    end

    it 'renders without layout when view class does not match prefix' do
      klass = Class.new(Phlex::HTML) do
        include Phlexible::Rails::AutoLayout

        def view_template
          span { 'no prefix' }
        end
      end

      render klass.new

      assert_equal '<span>no prefix</span>', @response
    end

    it 'renders without layout when view name is empty (anonymous class)' do
      klass = Class.new(Phlex::HTML) do
        include Phlexible::Rails::AutoLayout

        def view_template
          span { 'anonymous' }
        end
      end

      render klass.new

      assert_equal '<span>anonymous</span>', @response
    end
  end

  describe 'controller-assigned layout' do
    it 'uses controller-assigned layout when view_assigns has layout' do
      custom_layout = Class.new(Phlex::HTML) do
        def initialize(view)
          @view = view
        end

        def view_template(&block)
          div(id: 'custom-layout', &block)
        end
      end

      klass = Class.new(Phlex::HTML) do
        include Phlexible::Rails::AutoLayout

        def view_template
          span { 'content' }
        end
      end

      controller.instance_variable_set(:@layout, custom_layout)
      render klass.new

      assert_equal '<div id="custom-layout"><span>content</span></div>', @response
    ensure
      controller.instance_variable_set(:@layout, nil)
    end
  end

  describe 'configuration' do
    it 'uses custom view prefix' do
      stub_const('Pages', Module.new)
      stub_const('Pages::Layouts', Module.new)

      layout_klass = Class.new(Phlex::HTML) do
        def initialize(view)
          @view = view
        end

        def view_template(&block)
          div(id: 'pages-layout', &block)
        end
      end
      Pages::Layouts.const_set(:Application, layout_klass)

      stub_const('Pages::Home', Module.new)
      view_klass = Class.new(Phlex::HTML) do
        include Phlexible::Rails::AutoLayout

        self.auto_layout_view_prefix = 'Pages::'
        self.auto_layout_namespace = 'Pages::Layouts::'
        self.auto_layout_default = 'Pages::Layouts::Application'

        def view_template
          span { 'home' }
        end
      end
      Pages::Home.const_set(:Index, view_klass)

      render view_klass.new

      assert_equal '<div id="pages-layout"><span>home</span></div>', @response
    ensure
      if Pages::Layouts.const_defined?(:Application)
        Pages::Layouts.send(:remove_const, :Application)
      end
      Pages::Home.send(:remove_const, :Index) if Pages::Home.const_defined?(:Index)
      Object.send(:remove_const, :Pages) if Object.const_defined?(:Pages)
    end

    it 'uses nil prefix to match all view classes' do
      Views::Admin::Index.auto_layout_view_prefix = nil
      Views::Admin::Index.reset_resolved_layout!

      render Views::Admin::Index.new

      assert_equal '<div id="admin-layout"><span>admin index</span></div>', @response
    ensure
      Views::Admin::Index.auto_layout_view_prefix = 'Views::'
      Views::Admin::Index.reset_resolved_layout!
    end
  end

  describe 'callbacks' do
    it 'runs before_layout callback' do
      klass = Class.new(Views::Admin::Index) do
        before_layout :prepend_content

        private

          def prepend_content
            span { 'before' }
          end
      end

      render klass.new

      assert_equal '<span>before</span><div id="admin-layout"><span>admin index</span></div>',
                   @response
    end

    it 'runs after_layout callback' do
      klass = Class.new(Views::Admin::Index) do
        after_layout :append_content

        private

          def append_content
            span { 'after' }
          end
      end

      render klass.new

      assert_equal '<div id="admin-layout"><span>admin index</span></div><span>after</span>',
                   @response
    end

    it 'runs around_layout callback' do
      klass = Class.new(Views::Admin::Index) do
        around_layout :wrap_content

        private

          def wrap_content
            span { 'before' }
            yield
            span { 'after' }
          end
      end

      render klass.new

      assert_equal '<span>before</span><div id="admin-layout"><span>admin index</span></div>' \
                   '<span>after</span>',
                   @response
    end

    it 'runs before_layout with a block' do
      klass = Class.new(Views::Admin::Index) do
        before_layout do
          span { 'block-before' }
        end
      end

      render klass.new

      assert_equal '<span>block-before</span><div id="admin-layout"><span>admin index</span></div>',
                   @response
    end
  end

  describe '@layout instance variable' do
    it 'sets @layout on the view' do
      view = Views::Admin::Index.new
      render view

      assert_instance_of Views::Layouts::Admin, view.instance_variable_get(:@layout)
    end
  end

  describe 'view passed to layout' do
    it 'passes view instance to layout constructor' do
      received_view = nil
      layout_klass = Class.new(Phlex::HTML) do
        define_method(:initialize) do |view|
          received_view = view
          @view = view
        end

        def view_template(&block)
          div(&block)
        end
      end

      klass = Class.new(Phlex::HTML) do
        include Phlexible::Rails::AutoLayout

        def view_template
          span { 'content' }
        end
      end

      controller.instance_variable_set(:@layout, layout_klass)
      instance = klass.new
      render instance

      assert_same instance, received_view
    ensure
      controller.instance_variable_set(:@layout, nil)
    end
  end

  private

    def stub_const(name, value)
      (@stubbed_consts ||= []) << name
      parts = name.to_s.split('::')
      parent = parts.length > 1 ? parts[0..-2].join('::').constantize : Object
      parent.const_set(parts.last.to_sym, value) if !parent.const_defined?(parts.last.to_sym)
    end
end
