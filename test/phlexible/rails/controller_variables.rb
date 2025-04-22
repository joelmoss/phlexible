# frozen_string_literal: true

require 'rails_helper'

describe Phlexible::Rails::ControllerVariables do
  include RenderHelper

  def before
    # Reset controller variables
    Views::Articles::Show.__controller_variables__ = Set.new
  end

  it 'exposes controller variable' do
    controller.instance_variable_set :@article, 'article1'
    Views::Articles::Show.controller_variable :article

    render_to_html(view = Views::Articles::Show.new)

    expect(view.instance_variable_get(:@article)).to be == 'article1'
  end

  it 'sets name with :as' do
    controller.instance_variable_set :@article, 'article1'
    Views::Articles::Show.controller_variable :article, as: :article_name

    render_to_html(view = Views::Articles::Show.new)

    expect(view.instance_variable_get(:@article)).to be_nil
    expect(view.instance_variable_get(:@article_name)).to be == 'article1'
  end

  it 'accepts hash' do
    controller.instance_variable_set :@article, 'article1'
    Views::Articles::Show.controller_variable(article: :article_name)

    render_to_html(view = Views::Articles::Show.new)

    expect(view.instance_variable_get(:@article)).to be_nil
    expect(view.instance_variable_get(:@article_name)).to be == 'article1'
  end

  it 'accepts multiple names' do
    controller.instance_variable_set :@first_name, 'Joel'
    controller.instance_variable_set :@last_name, 'Moss'
    Views::Articles::Show.controller_variable(:first_name, :last_name)

    render_to_html(view = Views::Articles::Show.new)

    expect(view.instance_variable_get(:@first_name)).to be == 'Joel'
    expect(view.instance_variable_get(:@last_name)).to be == 'Moss'
  end

  it 'accepts names and hash' do
    controller.instance_variable_set :@first_name, 'Joel'
    controller.instance_variable_set :@last_name, 'Moss'
    Views::Articles::Show.controller_variable(:first_name, last_name: :surname)

    render_to_html(view = Views::Articles::Show.new)

    expect(view.instance_variable_get(:@first_name)).to be == 'Joel'
    expect(view.instance_variable_get(:@last_name)).to be_nil
    expect(view.instance_variable_get(:@surname)).to be == 'Moss'
  end

  it 'accepts hash with :as key' do
    controller.instance_variable_set :@article, 'article1'
    Views::Articles::Show.controller_variable(article: { as: :article_name })

    render_to_html(view = Views::Articles::Show.new)

    expect(view.instance_variable_get(:@article)).to be_nil
    expect(view.instance_variable_get(:@article_name)).to be == 'article1'
  end

  it 'raises on undefined var' do
    Views::Articles::Show.controller_variable :article

    expect do
      render_to_html Views::Articles::Show.new
    end.to raise_exception(Phlexible::Rails::ControllerVariables::UndefinedVariable)
  end

  it 'allow_undefined: true' do
    Views::Articles::Show.controller_variable :article, allow_undefined: true

    render_to_html(view = Views::Articles::Show.new)

    expect(view.instance_variable_get(:@article)).to be_nil
  end

  it 'allow_undefined: false' do
    Views::Articles::Show.controller_variable :article, allow_undefined: false

    expect do
      render_to_html Views::Articles::Show.new
    end.to raise_exception(Phlexible::Rails::ControllerVariables::UndefinedVariable)
  end

  it 'with hash and allow_undefined: true' do
    Views::Articles::Show.controller_variable article: { allow_undefined: true }

    render_to_html(view = Views::Articles::Show.new)

    expect(view.instance_variable_get(:@article)).to be_nil
  end

  it 'with hash and allow_undefined: false' do
    Views::Articles::Show.controller_variable article: { allow_undefined: false }

    expect do
      render_to_html Views::Articles::Show.new
    end.to raise_exception(Phlexible::Rails::ControllerVariables::UndefinedVariable)
  end

  it 'with hash and allow_undefined in both args' do
    Views::Articles::Show.controller_variable article: { allow_undefined: false }, allow_undefined: true

    expect do
      render_to_html Views::Articles::Show.new
    end.to raise_exception(Phlexible::Rails::ControllerVariables::UndefinedVariable)
  end

  it 'with hash and allow_undefined in both args' do
    Views::Articles::Show.controller_variable article: { allow_undefined: true }, allow_undefined: false

    render_to_html(view = Views::Articles::Show.new)

    expect(view.instance_variable_get(:@article)).to be_nil
  end
end
