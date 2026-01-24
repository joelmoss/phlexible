# frozen_string_literal: true

require_relative 'lib/phlexible/version'

Gem::Specification.new do |spec|
  spec.name = 'phlexible'
  spec.version = Phlexible::VERSION
  spec.authors = ['Joel Moss']
  spec.email = ['joel@developwithstyle.com']

  spec.summary = 'A bunch of helpers and goodies intended to make life with Phlex even easier!'
  spec.description = 'A bunch of helpers and goodies intended to make life with Phlex even easier!'
  spec.homepage = 'https://github.com/joelmoss/phlexible'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/joelmoss/phlexible'
  spec.metadata['changelog_uri'] = 'https://github.com/joelmoss/phlexible/releases'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ .git .github Gemfile])
    end
  end

  spec.require_paths = ['lib']

  spec.add_dependency 'phlex', '>= 1.10.0', '< 3.0.0'
  spec.add_dependency 'phlex-rails', '>= 1.2.0', '< 3.0.0'
  spec.add_dependency 'rails', '>= 7.2.0', '< 9.0.0'
  spec.add_dependency 'zeitwerk', '~> 2.7.2'
end
