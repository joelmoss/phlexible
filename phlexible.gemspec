# frozen_string_literal: true

require_relative 'lib/phlexible/version'

Gem::Specification.new do |spec|
  spec.name = 'phlexible'
  spec.version = Phlexible::VERSION
  spec.authors = ['Joel Moss']
  spec.email = ['joel@developwithstyle.com']

  spec.summary = 'A bunch of helpers and goodies intended to make life with [Phlex](https://phlex.fun) even easier!'
  spec.description = 'A bunch of helpers and goodies intended to make life with [Phlex](https://phlex.fun) even easier!'
  spec.homepage = 'https://github.com/joelmoss/phlexible'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/joelmoss/phlexible'
  spec.metadata['changelog_uri'] = 'https://github.com/joelmoss/phlexible/releases'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'phlex', '~> 1.0'
  spec.add_dependency 'phlex-rails', '~> 0.4'
end
