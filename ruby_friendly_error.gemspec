# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby_friendly_error/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruby_friendly_error'
  spec.version       = RubyFriendlyError::VERSION
  spec.authors       = ['isuke']
  spec.email         = ['isuke770@gmail.com']

  spec.summary       = 'make to ruby error messages friendly.'
  spec.description   = 'make to ruby error messages friendly. Display multilingual message and error lines'
  spec.homepage      = 'https://github.com/isuke/ruby_friendly_error'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'colorize', '~> 0.8'
  spec.add_dependency 'i18n'    , '~> 1.1'
  spec.add_dependency 'parser'  , '~> 2.5'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake'   , '~> 10.0'
end
