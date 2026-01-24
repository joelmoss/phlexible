# frozen_string_literal: true

require 'test_helper'

class Phlexible::Rails::ControllerVariablesTest < ActiveSupport::TestCase
  def setup
    # Reset controller variables
    Views::Articles::Show.__controller_variables__ = Set.new
  end

  it 'exposes controller variable' do
    controller.instance_variable_set :@article, 'article1'
    Views::Articles::Show.controller_variable :article

    render(view = Views::Articles::Show.new)

    assert_equal 'article1', view.instance_variable_get(:@article)
  end

  it 'sets name with :as' do
    controller.instance_variable_set :@article, 'article1'
    Views::Articles::Show.controller_variable :article, as: :article_name

    render(view = Views::Articles::Show.new)

    assert_nil view.instance_variable_get(:@article)
    assert_equal 'article1', view.instance_variable_get(:@article_name)
  end

  it 'accepts hash' do
    controller.instance_variable_set :@article, 'article1'
    Views::Articles::Show.controller_variable(article: :article_name)

    render(view = Views::Articles::Show.new)

    assert_nil view.instance_variable_get(:@article)
    assert_equal 'article1', view.instance_variable_get(:@article_name)
  end

  it 'accepts multiple names' do
    controller.instance_variable_set :@first_name, 'Joel'
    controller.instance_variable_set :@last_name, 'Moss'
    Views::Articles::Show.controller_variable(:first_name, :last_name)

    render(view = Views::Articles::Show.new)

    assert_equal 'Joel', view.instance_variable_get(:@first_name)
    assert_equal 'Moss', view.instance_variable_get(:@last_name)
  end

  it 'accepts names and hash' do
    controller.instance_variable_set :@first_name, 'Joel'
    controller.instance_variable_set :@last_name, 'Moss'
    Views::Articles::Show.controller_variable(:first_name, last_name: :surname)

    render(view = Views::Articles::Show.new)

    assert_equal 'Joel', view.instance_variable_get(:@first_name)
    assert_nil view.instance_variable_get(:@last_name)
    assert_equal 'Moss', view.instance_variable_get(:@surname)
  end

  it 'accepts hash with :as key' do
    controller.instance_variable_set :@article, 'article1'
    Views::Articles::Show.controller_variable(article: { as: :article_name })

    render(view = Views::Articles::Show.new)

    assert_nil view.instance_variable_get(:@article)
    assert_equal 'article1', view.instance_variable_get(:@article_name)
  end

  it 'raises on undefined var' do
    Views::Articles::Show.controller_variable :article

    assert_raises(Phlexible::Rails::ControllerVariables::UndefinedVariable) do
      render Views::Articles::Show.new
    end
  end

  it 'allow_undefined: true' do
    Views::Articles::Show.controller_variable :article, allow_undefined: true

    render(view = Views::Articles::Show.new)

    assert_nil view.instance_variable_get(:@article)
  end

  it 'allow_undefined: false' do
    Views::Articles::Show.controller_variable :article, allow_undefined: false

    assert_raises(Phlexible::Rails::ControllerVariables::UndefinedVariable) do
      render Views::Articles::Show.new
    end
  end

  it 'with hash and allow_undefined: true' do
    Views::Articles::Show.controller_variable article: { allow_undefined: true }

    render(view = Views::Articles::Show.new)

    assert_nil view.instance_variable_get(:@article)
  end

  it 'with hash and allow_undefined: false' do
    Views::Articles::Show.controller_variable article: { allow_undefined: false }

    assert_raises(Phlexible::Rails::ControllerVariables::UndefinedVariable) do
      render Views::Articles::Show.new
    end
  end

  it 'with hash and allow_undefined in both args (hash takes precedence - false)' do
    Views::Articles::Show.controller_variable article: { allow_undefined: false },
                                              allow_undefined: true

    assert_raises(Phlexible::Rails::ControllerVariables::UndefinedVariable) do
      render Views::Articles::Show.new
    end
  end

  it 'with hash and allow_undefined in both args (hash takes precedence - true)' do
    Views::Articles::Show.controller_variable article: { allow_undefined: true },
                                              allow_undefined: false

    render(view = Views::Articles::Show.new)

    assert_nil view.instance_variable_get(:@article)
  end
end
