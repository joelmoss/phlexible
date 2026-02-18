# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Phlexible is a Ruby gem providing helpers and extensions for [Phlex](https://phlex.fun) views in Rails applications. It supports Phlex 1.x and 2.x across Rails 7.2+ and Ruby >= 3.3.

## Commands

### Tests

Tests use Minitest (with maxitest, minitest-focus, minitest-spec-rails). The project uses [Appraisal](https://github.com/thoughtbot/appraisal) to test across multiple Phlex/Rails version combinations defined in `Appraisals`.

```bash
# Run all tests across all appraisals (phlex1/rails7, phlex1/rails8, phlex2/rails7, phlex2/rails8)
bundle exec appraisal rails test

# Run tests for a specific appraisal
bundle exec appraisal phlex2/rails8 rails test

# Run a single test file
bundle exec appraisal phlex2/rails8 rails test test/phlexible/alias_view_test.rb

# Run a single test by line number
bundle exec appraisal phlex2/rails8 rails test test/phlexible/alias_view_test.rb:10

# Focus a single test (add `focus` before the test method, provided by minitest-focus)
```

### Lint

```bash
bundle exec rubocop -P --fail-level C
```

### Setup

```bash
bin/setup
bundle exec appraisal install
```

## Architecture

All source code lives under `lib/phlexible/`. Autoloading is handled by Zeitwerk (`Zeitwerk::Loader.for_gem` in `lib/phlexible.rb`).

### Module Organization

Modules are split into two categories:

**Standalone modules** (no Rails dependency):
- `Phlexible::AliasView` — `extend` in a view to create shortcut methods for rendering other components
- `Phlexible::Callbacks` — `include` for ActiveSupport::Callbacks-based `before_template`/`after_template`/`around_template` hooks. Also provides `before_layout`/`after_layout`/`around_layout` when used with `AutoLayout`.
- `Phlexible::PageTitle` — `include` for hierarchical page title management across nested views
- `Phlexible::ProcessAttributes` — `extend` to intercept and modify HTML element attributes before rendering (Phlex 2.x only; Phlex 1.x has this built-in). Prepends wrappers onto all StandardElements, VoidElements, and custom `register_element` methods.

**Rails-specific modules** (`lib/phlexible/rails/`):
- `ActionController::ImplicitRender` — convention-based automatic Phlex view rendering (resolves `UsersController#index` to `Users::IndexView`)
- `ControllerVariables` — explicit interface to expose controller instance variables to Phlex views via `controller_variable` class method
- `AElement` — overrides `a` tag to pass `href` through Rails `url_for`
- `ButtonTo` — Phlex component replacing Rails `button_to` helper
- `Responder` — integration with the [Responders](https://github.com/heartcombo/responders) gem
- `AutoLayout` — automatic layout wrapping based on view namespace conventions (e.g., `Views::Admin::Index` resolves to `Views::Layouts::Admin`). Includes `ViewAssigns` and `Callbacks`. Layout resolution is cached per class in production.
- `MetaTags` / `MetaTagsComponent` — define meta tags in controllers, render in views

### Key Patterns

- Modules use `extend` (AliasView, ProcessAttributes) or `include` (Callbacks, PageTitle, ControllerVariables) depending on whether they add class-level or instance-level behavior.
- `ProcessAttributes` uses `class_eval` with string interpolation to dynamically wrap every HTML element method — be careful when modifying this.
- `ControllerVariables` depends on both `ViewAssigns` and `Callbacks` internally.
- `AutoLayout` depends on both `ViewAssigns` and `Callbacks`. Layout resolution is cached in production via `resolved_layout` class method; use `reset_resolved_layout!` to clear.
- Tests use a Rails dummy app at `test/dummy/` for integration testing with real controllers/routes.

## Style

- RuboCop enforced with `rubocop-rails`, `rubocop-minitest`, `rubocop-performance`, `rubocop-packaging`, `rubocop-rake`.
- `unless`, `and`/`or`/`not`, and numbered parameters are **disabled** via `rubocop-disable_syntax`.
- `indented_internal_methods` indentation style (private methods indented one extra level).
- Max line length: 100 characters.
